# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parameter
    REF boost-1.78.0
    SHA512 9e524ed3627852962b6a7a8dd324341b1ef181aac5300e78065846ee20dc110cdcfab348e02050d4cd82ff800ef361c980a1b3c95da2c24372aedb581fe8478d
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-parameter requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
