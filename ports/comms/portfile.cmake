vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms
    REF "v${VERSION}"
    SHA512 832228872ab688c7a87f1c89844e490ac1ab36e4be06f61d9ff9182912da79ec84d6b3e63bba0547310c6639a568a0419f036e4a81098f445165e27c1563fc0d
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCC_COMMS_BUILD_UNIT_TESTS=OFF
        -DBUILD_TESTING=OFF
        -DCC_COMMS_WARN_AS_ERR=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibComms CONFIG_PATH lib/LibComms/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
