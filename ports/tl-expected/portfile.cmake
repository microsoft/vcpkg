include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/expected
    REF v1.0.0
    SHA512 747ea34b5540dfcf595896332851f10c52a823ab8ba3fc8152478b0a9e8ca01f0f26827348407249827f4106ff577bd6e697ea6f749c1f21bd1f0913a621075d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DEXPECTED_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tl-expected RENAME copyright)
