vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO halide/Halide
    REF "v${VERSION}"
    SHA512 474fe321f28dd88f8c681d41b9f4d828230e3db5ed69d6a0e08fa3e5143d6cebb294f226f34b0d4c1c5fa276e53401fbbfb33555c20ee07a01f8048d8ca170de
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "autoschedulers" WITH_AUTOSCHEDULERS
        "serialization" WITH_SERIALIZATION
        "python-bindings" WITH_PYTHON_BINDINGS
)

if("python-bindings" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS
        -DHalide_Python_INSTALL_CMAKEDIR=share/Halide_Python
    )
endif()

set(CASE_SENSITIVE_PORT_NAME Halide)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWITH_DOCS=OFF
        -DWITH_TESTS=OFF
        -DWITH_TUTORIALS=OFF
        -DWITH_UTILS=OFF
        -DHalide_WASM_BACKEND=OFF # Disables in-process WASM testing
        -DHalide_INSTALL_CMAKEDIR=share/${CASE_SENSITIVE_PORT_NAME}
        -DHalide_INSTALL_HELPERSDIR=share/HalideHelpers
        -DHalide_INSTALL_PLUGINDIR=tools/${CASE_SENSITIVE_PORT_NAME}
        -DHalide_INSTALL_TOOLSDIR=tools/${CASE_SENSITIVE_PORT_NAME}
        -DCMAKE_DISABLE_FIND_PACKAGE_PNG=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=TRUE
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${CASE_SENSITIVE_PORT_NAME}")
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${CASE_SENSITIVE_PORT_NAME})
vcpkg_cmake_config_fixup(PACKAGE_NAME HalideHelpers)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
