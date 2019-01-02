include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF v1.0.22
    SHA512 b1fed66aafa82490889ee488832c6884a95d38ce7b28fb7c3234b9bce1f749455d7b91cde397a0abc25101410edb13ab2f9832c59aa7b0ea8c19ba2cf4c63b00
    HEAD_REF master
)

if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
  set(MSVS_VERSION 2017)
else()
  set(MSVS_VERSION 2015)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBUSB_PROJECT_TYPE dll)
else()
    set(LIBUSB_PROJECT_TYPE static)
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj
    LICENSE_SUBPATH COPYING
)

file(INSTALL
    ${SOURCE_PATH}/libusb/libusb.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/libusb-1.0
)
