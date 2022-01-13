# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/serialization
    REF boost-1.78.0
    SHA512 12ae48c01fea6102267cc642727fc091ddb30224ecfb302911089dd2904fb7e52a03d5154059bb15d903753fd3863de8185612b1848418775f23e2a50378ed82
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-serialization requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/vcpkg_boost_build.cmake)
vcpkg_boost_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
