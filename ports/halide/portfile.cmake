vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF "v${VERSION}"
    SHA512 474fe321f28dd88f8c681d41b9f4d828230e3db5ed69d6a0e08fa3e5143d6cebb294f226f34b0d4c1c5fa276e53401fbbfb33555c20ee07a01f8048d8ca170de
    HEAD_REF main
    PATCHES
        fix-llvm-23.patch
)

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
        -DHalide_INSTALL_HELPERSDIR=share/HalideHelpers
        -DHalide_INSTALL_PLUGINDIR=bin
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
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideHelpers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
