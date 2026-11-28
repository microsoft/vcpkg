set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zhangglnuo-art/multichain-address-validator-cpp
    REF "v${VERSION}"
    SHA512 b5192b2ad731f531f17591e5d209f3ebe8d7cb9e7703ea6b7c1a3c827c6ebf550eccb45293aa988a66c17fd3b37e1c574ea168432b08dcd2f1a21db75b3d7143
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/include/allswap" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
