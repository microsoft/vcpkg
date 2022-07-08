vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mtszb/libaiff
    REF a58801a9d2ab09b2d1b578609a6337b95e22c8fb #v6.0
    SHA512 25925f36fe4ddf29a8986d0265ca66b85b5c02673915c742913b2f0d89b349b000abc9cd57c9806ad71bc6c1a7949cff4b943284e68c35b18eb81641bfdbcc5f
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_make()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
