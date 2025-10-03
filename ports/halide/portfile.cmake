vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF "v${VERSION}"
    SHA512 474fe321f28dd88f8c681d41b9f4d828230e3db5ed69d6a0e08fa3e5143d6cebb294f226f34b0d4c1c5fa276e53401fbbfb33555c20ee07a01f8048d8ca170de
    HEAD_REF main
)

set(CASE_SENSITIVE_PORT_NAME Halide)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_DOCS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TUTORIALS=OFF
        -DWITH_UTILS=OFF
        -DWITH_AUTOSCHEDULERS=OFF
        -DWITH_PYTHON_BINDINGS=OFF
        -DWITH_SERIALIZATION=OFF
        -DHalide_WASM_BACKEND=OFF # Disables in-process WASM testing
        -DCMAKE_INSTALL_DATADIR=share/${CASE_SENSITIVE_PORT_NAME}
        -DHalide_INSTALL_CMAKEDIR=share/${CASE_SENSITIVE_PORT_NAME}
        -DHalide_INSTALL_HELPERSDIR=share/HalideHelpers
        -DCMAKE_DISABLE_FIND_PACKAGE_PNG=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=TRUE)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_copy_tools(DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${CASE_SENSITIVE_PORT_NAME}" TOOL_NAMES gengen AUTO_CLEAN)
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${CASE_SENSITIVE_PORT_NAME})
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideHelpers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
