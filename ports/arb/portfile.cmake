vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredrik-johansson/arb
    REF e3a633dcc1adafeb7ca9648669f2b1fa2f433ee1 # 2.21.1
    SHA512 af864ea4f849d12dbaadec8cda7e6b1a7d349b7aa776966ec7f61ad7a5186dc3f280512218bcff28901e2d55d6c976525746e6de13925a9942ed947ac2253af6
    HEAD_REF master
    PATCHES fix-build-error.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_MT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSVC_USE_MT=${MSVC_USE_MT}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove duplicate headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)