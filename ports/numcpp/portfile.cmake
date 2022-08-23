# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF bdbfa50f96b370f30bf7f130b445e714654daa76 #Version_2.8.0
    SHA512 c59b0a8f71e19eb67337bcb8f3a9493c22d68056091cdf24d0d3fd7511b5590cc184f6271505220f6d8f3364ea03db7f84c6ccf2ce85cd44703d877d63e14704
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNUMCPP_NO_USE_BOOST=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME NumCpp CONFIG_PATH share/NumCpp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
