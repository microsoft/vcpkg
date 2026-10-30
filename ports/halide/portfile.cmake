vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF "v${VERSION}"
    SHA512 f3c66eb5e3e9a2f811947231d571d755919bbc07c83dcdafcc379cb7540b5816f3e3192523b2a3ac60832e50ae94a0a87ca92a1ac75cc6617405d13ab9507c93
    HEAD_REF main
)

# The autoscheduler plugins are loaded at run time. On Windows they go next to
# Halide.dll; elsewhere, keep them out of bin/, which vcpkg_cmake_config_fixup
# treats as the tools directory.
if (VCPKG_TARGET_IS_WINDOWS)
    set(plugin_dir bin)
else ()
    set(plugin_dir lib)
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHalide_WASM_BACKEND=OFF
        -DWITH_DOCS=OFF
        -DWITH_PYTHON_BINDINGS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TUTORIALS=OFF
        -DWITH_UTILS=OFF
        -DWITH_SERIALIZATION=OFF # Disable experimental serializer
        -DCMAKE_INSTALL_LIBDIR=bin
        "-DCMAKE_INSTALL_DATADIR=share/${PORT}"
        "-DHalide_INSTALL_CMAKEDIR=share/${PORT}"
        -DHalide_INSTALL_COMPILERDIR=share/HalideCompiler
        -DHalide_INSTALL_AUTOSCHEDULERSDIR=share/HalideAutoschedulers
        "-DHalide_INSTALL_PLUGINDIR=${plugin_dir}"
        -DCMAKE_DISABLE_FIND_PACKAGE_PNG=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=JPEG
)

# ADD_BIN_TO_PATH needed to compile autoschedulers, 
# which use Halide.dll (and deps) during the build.
vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_copy_tools(TOOL_NAMES gengen AUTO_CLEAN)

# Release mode MODULE targets in CMake don't get PDBs.
# Exclude those to avoid warning with default globs.
vcpkg_copy_pdbs(
    BUILD_PATHS
        "${CURRENT_PACKAGES_DIR}/bin/Halide.dll" 
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
)

vcpkg_cmake_config_fixup()
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideCompiler)
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideAutoschedulers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
