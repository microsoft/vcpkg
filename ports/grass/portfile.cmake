set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
# GRASS modules (lib/grass85/bin/*.exe) load their DLLs from the same directory
set(VCPKG_POLICY_ALLOW_DLLS_IN_LIB enabled)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osgeo/grass
    REF "${VERSION}"
    SHA512 0829ad936390fe6c59abfb363a0e4f1ab4210e5903ec847d4df34541029d13d2b7700e69efb106f31bb6d92c64b4d8890e93b066758ab30ec06a132be047c6ca
    PATCHES
        ogsf-windows-gl.patch
        libsvm-cxx-link.patch
        parson-prefix-symbols.patch
        readline-static-deps.patch
        v-out-ogr-featuredefn.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    openmp          WITH_OPENMP
    x11             WITH_X11
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)

set(EXTRA_OPTIONS "")
set(RELEASE_OPTIONS "")

if(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Static GDAL is linked into several GRASS libraries: keep each copy
        # private to avoid HDF5 crashes at runtime (macOS already does this).
        string(APPEND VCPKG_LINKER_FLAGS " -Wl,--exclude-libs,ALL")
    endif()
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND EXTRA_OPTIONS "-DWITH_READLINE=ON")
else()
    # GRASS's FindPCRE always prefers the debug library if it exists:
    # point it to the release one in release builds.
    list(APPEND RELEASE_OPTIONS "-DPCRE_LIBRARY_DEBUG=${CURRENT_INSTALLED_DIR}/lib/pcre.lib")

    # GRASS runs its own tools during the build with the PATH captured at
    # configure time: make the dependency DLLs reachable.
    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -DWITH_BZLIB=ON
        -DWITH_DOCS=OFF
        -DWITH_GUI=OFF
        -DWITH_LAPACKE=OFF
        -DWITH_LIBSVM=ON
    OPTIONS_RELEASE
        ${RELEASE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME grass CONFIG_PATH lib/cmake/GRASS)
set(cfg "${CURRENT_PACKAGES_DIR}/share/grass/GRASSConfig.cmake")
file(READ "${cfg}" content)
string(REGEX REPLACE "set\\(GRASS_CMAKE_DIR \"[^\"]*\"\\)"
    "set(GRASS_CMAKE_DIR \"\${PACKAGE_PREFIX_DIR}/lib/grass85/etc/cmake\")" content "${content}")
string(REGEX REPLACE "set\\(GRASS_UTILS_DIR \"[^\"]*\"\\)"
    "set(GRASS_UTILS_DIR \"\${PACKAGE_PREFIX_DIR}/lib/grass85/utils\")" content "${content}")
string(REGEX REPLACE "set\\(GRASS_([A-Za-z]+)_INCLUDE_(DIRS?) \"[^\"]*\"\\)"
    "set(GRASS_\\1_INCLUDE_\\2 \"\${PACKAGE_PREFIX_DIR}/include\")" content "${content}")
file(WRITE "${cfg}" "${content}")

# Replace absolute build paths with relative ones
foreach(prefix_dir IN ITEMS "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/debug")
    if(NOT EXISTS "${prefix_dir}/lib/grass85")
        continue()
    endif()
    # PROJ data is only in the release prefix: debug needs one more level up
    if(prefix_dir STREQUAL "${CURRENT_PACKAGES_DIR}")
        set(proj_parent 6)
    else()
        set(proj_parent 7)
    endif()

    # Launcher
    if(VCPKG_TARGET_IS_WINDOWS)
        set(launcher "${prefix_dir}/bin/grass.py")
    else()
        set(launcher "${prefix_dir}/bin/grass")
    endif()
    file(TO_NATIVE_PATH "${prefix_dir}/lib/grass85/etc/python" native_pydir)
    if(EXISTS "${launcher}")
        vcpkg_replace_string("${launcher}"
            "r\"${native_pydir}\""
            "str(Path(__file__).resolve().parent.parent / \"lib\" / \"grass85\" / \"etc\" / \"python\")")
    endif()

    # resource_paths.py: compute paths from the file location
    # (<prefix>/lib/grass85/etc/python/grass/app/resource_paths.py)
    set(rp "${prefix_dir}/lib/grass85/etc/python/grass/app/resource_paths.py")
    file(READ "${rp}" content)
    string(REGEX REPLACE "CONFIG_PROJSHARE = \"[^\"]*\""
        "import pathlib\nCONFIG_PROJSHARE = str(pathlib.Path(__file__).resolve().parents[${proj_parent}] / \"share\" / \"proj\")"
        content "${content}")
    string(REGEX REPLACE "GRASS_PREFIX = \"[^\"]*\""
        "GRASS_PREFIX = str(pathlib.Path(__file__).resolve().parents[6])"
        content "${content}")
    string(REGEX REPLACE "GRASS_CMAKE_PREFIX_PATH = \"[^\"]*\"" "GRASS_CMAKE_PREFIX_PATH = \"\"" content "${content}")
    string(REGEX REPLACE "GRASS_CMAKE_C_COMPILER = \"[^\"]*\"" "GRASS_CMAKE_C_COMPILER = \"\"" content "${content}")
    string(REGEX REPLACE "GRASS_CMAKE_CXX_COMPILER = \"[^\"]*\"" "GRASS_CMAKE_CXX_COMPILER = \"\"" content "${content}")
    file(WRITE "${rp}" "${content}")

    # ctypes wrappers: remove build paths from comments
    file(GLOB ctypes_py "${prefix_dir}/lib/grass85/etc/python/grass/lib/*.py")
    foreach(f IN LISTS ctypes_py)
        file(READ "${f}" content)
        string(REGEX REPLACE "\n[^\n]*libgrass_interface_generator/run\\.py[^\n]*\n" "\n" content "${content}")
        foreach(p IN ITEMS "${CURRENT_PACKAGES_DIR}/" "${CURRENT_INSTALLED_DIR}/" "${CURRENT_BUILDTREES_DIR}/")
            string(REPLACE "${p}" "" content "${content}")
        endforeach()
        file(WRITE "${f}" "${content}")
    endforeach()

    # fontcap: keep only GRASS fonts (system fonts depend on the build machine)
    set(fc "${prefix_dir}/lib/grass85/etc/fontcap")
    if(EXISTS "${fc}")
        file(STRINGS "${fc}" lines)
        list(FILTER lines EXCLUDE REGEX "^[^|]*\\|[^|]*\\|1\\|")
        list(TRANSFORM lines REPLACE "\\|[^|]*/lib/grass85/fonts/" "|fonts/")
        list(JOIN lines "\n" content)
        file(WRITE "${fc}" "${content}\n")
    endif()

    # demolocation: remove build-only config file
    file(REMOVE "${prefix_dir}/lib/grass85/demolocation/.grassrc85")

    # Remove Python bytecode (regenerated at runtime)
    file(GLOB_RECURSE pycache_dirs LIST_DIRECTORIES true "${prefix_dir}/lib/grass85/*/__pycache__")
    list(FILTER pycache_dirs INCLUDE REGEX "/__pycache__$")
    if(pycache_dirs)
        file(REMOVE_RECURSE ${pycache_dirs})
    endif()
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
