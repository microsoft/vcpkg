# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/iostreams
    REF boost-1.82.0
    SHA512 2949f3612cbc809f723a16168ccfb39249ba1e730ec9fa5201a41189bbce22b35e9adeb1478f7cbf012346f67ac7d8841770c8f977711ef0aea0fd6dd01dd785
    HEAD_REF master
    PATCHES 
        Removeseekpos.patch
        fix-zstd.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
