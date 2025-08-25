# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tonitaga/defer
    REF d07865980ee28b7552bcc4645644db4f01a57f1e
    SHA512 7c01a1b0e721ee503edc371e9ec6ccfebe523bda6669e06c82fa1456d0c7e5fc5915ebad3dcc9e69d61c8394ea6139707c79d1160c8ffcb2100f7e29fd5064ec
    HEAD_REF main
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME defer CONFIG_PATH share/defer/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")