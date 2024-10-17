vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzlaine/parser
    REF 9b03f3c1f9402d33807b68badd6d8219a11359d1
    SHA512 94475821acac20f89adcdb6079875f9476b1da46f3f9ddfbe36de08b87513bbc768921d8e6b801326f25c8185b974a2a153bfb66654f31696bf935b3cd24dfcb
    HEAD_REF main
    PATCHES add-install-configuration.patch
)
message (FATAL "not finished")

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_HANA=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
