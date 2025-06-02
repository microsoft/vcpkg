if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_IOS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/OpenSubdiv
    REF 8ffa2b6566be10209529d7a0d1db02a0796b160c # v3.5.0
    SHA512 cb48470f044ca4e9fcdfb3ff05d710fd710212d5a2f539f3f90ebb33cc6a6b1530fd9deb7d3eb25b275133dbdf5c1a5d4777b289d13b15006a59db12e8b28398
    HEAD_REF release
    PATCHES
        fix_compile-option.patch
        fix-version-search.patch
        fix-build-type.patch
        fix-dependencies.patch
        fix-feature-cuda.patch
        fix-notfind-header.patch
)

if(VCPKG_TARGET_IS_LINUX)
    message(
"OpenSubdiv currently requires the following libraries from the system package manager:
    xinerama xxf86vm

These can be installed on Ubuntu systems via sudo apt install libxinerama-dev libxxf86vm-dev")
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(STATIC_CRT_LNK ON)
else()
    set(STATIC_CRT_LNK OFF)
endif()

if ("cuda" IN_LIST FEATURES AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    message(FATAL_ERROR "Feature 'cuda' can only build on x64 arch.")
endif()

if (("dx" IN_LIST FEATURES OR "omp" IN_LIST FEATURES) AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature 'dx' and 'omp' only support Windows.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "true-deriv-eval"   OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES
    INVERTED_FEATURES
        "cuda"      NO_CUDA
        "dx"        NO_DX
        "examples"  NO_EXAMPLES
        "glew"      NO_GLEW
        "glfw"      NO_GLFW
        "glfw"      NO_GLFW_X11
        "omp"       NO_OMP
        "opencl"    NO_OPENCL
        "opengl"    NO_OPENGL
        "ptex"      NO_PTEX
        "tbb"       NO_TBB
        "tutorials" NO_TUTORIALS
)

set(OSD_EXTRA_OPTS)
if ("ptex" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DPTEX_LOCATION=${CURRENT_INSTALLED_DIR})
endif()
if ("glew" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DGLEW_LOCATION=${CURRENT_INSTALLED_DIR})
endif()
if ("glfw" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DGLFW_LOCATION=${CURRENT_INSTALLED_DIR})
endif()
if ("dx" IN_LIST FEATURES)
    list(APPEND OSD_EXTRA_OPTS -DDXSDK_LOCATION=${CURRENT_INSTALLED_DIR})
endif()
if (VCPKG_TARGET_IS_OSX)
    list(APPEND OSD_EXTRA_OPTS -DNO_METAL=OFF)
else()
    list(APPEND OSD_EXTRA_OPTS -DNO_METAL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMSVC_STATIC_CRT=${STATIC_CRT_LNK}
        -DNO_LIB=OFF
        -DNO_REGRESSION=ON
        -DNO_DOC=ON
        -DNO_TESTS=ON
        -DNO_GLTESTS=ON
        -DNO_CLEW=ON
        ${FEATURE_OPTIONS}
        ${OSD_EXTRA_OPTS}
    MAYBE_UNUSED_VARIABLES
        MSVC_STATIC_CRT
)

vcpkg_cmake_install()

if ("examples" IN_LIST FEATURES)
    if ("dx" IN_LIST FEATURES)
        vcpkg_copy_tools(TOOL_NAMES dxViewer AUTO_CLEAN)
        if ("ptex" IN_LIST FEATURES)
            vcpkg_copy_tools(TOOL_NAMES dxPtexViewer AUTO_CLEAN)
        endif()
    endif()
endif()

if ("tutorials" IN_LIST FEATURES)
    file(GLOB TUTORIALS_TOOLS "${CURRENT_PACKAGES_DIR}/bin/tutorials/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    set(TUTORIALS_TOOL_NAMES )
    foreach(TUTORIALS_TOOL IN LISTS TUTORIALS_TOOLS)
        get_filename_component(TUTORIALS_TOOL_NAME "${TUTORIALS_TOOL}" NAME_WE)
        list(APPEND TUTORIALS_TOOL_NAMES "${TUTORIALS_TOOL_NAME}")
    endforeach()
    if (TUTORIALS_TOOL_NAMES)
        vcpkg_copy_tools(TOOL_NAMES ${TUTORIALS_TOOL_NAMES} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin/tutorials/" AUTO_CLEAN)
    endif()
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenSubdiv CONFIG_PATH lib/cmake/OpenSubdiv)
vcpkg_fixup_pkgconfig()

# The header files are read only and can't remove when remove this port
file(GLOB_RECURSE OSD_HDRS "${CURRENT_PACKAGES_DIR}/include/*.h")
file(CHMOD_RECURSE ${OSD_HDRS}
        PERMISSIONS
            OWNER_READ OWNER_WRITE
            GROUP_READ GROUP_WRITE
            WORLD_READ WORLD_WRITE
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/bin"
                    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
