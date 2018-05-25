include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiangfan-ms/hana
    REF caa985795ab6c4b2c7bcf1458ccbb6ded65c15cb
    SHA512 7ed65bda17042c42f7a76d88e66df61155800066119f6b256e20cf04dcd18d46584d3e44ad6555e9a17d9c0bf85fbf173ae6079f5a4a878341f959c855ebee6b
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
