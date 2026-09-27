vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/comms
    REF "v${VERSION}"
    SHA512 9cc085f108dcfec1444a8f80ec73f29b87b058bcb8e4de6a60553fde3e3f7de8d1f4a5446ec875a1d2b626ea69fa6037b8e0c7ce2609eb2807be10843a5afa3b
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
