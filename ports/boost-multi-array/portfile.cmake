# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multi_array
    REF boost-1.78.0
    SHA512 835a43e508ef2b2e03ecc8268770eb2e523414406d0da34ab5fdedf65e65b0f6d3dcfa8efbd2f4ee226331a56cb977106d8bdf8f285aa36f9055017be5be080b
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-multi-array requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
