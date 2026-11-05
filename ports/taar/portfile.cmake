vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rjahanbakhshi/boost.taar
    REF "v${VERSION}"
    SHA512 2a9719736b67dc561c92ad165f645d5b1bcedd4f715fed07d631b61680fed6f67cd0823e6e10370e4a38f2cda2a11caa98dcfe46518318554da24043eec7639f
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOOST_TAAR_BUILD_TESTS=OFF
        -DBOOST_TAAR_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME boost-taar CONFIG_PATH share/cmake/boost-taar)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
