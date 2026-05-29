vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hjson/hjson-cpp
    REF "${VERSION}"
    SHA512 ae97d44cbc3b896fb52cd435a7cfa7212025e2db718b316fe2b087d5b56f84b5a5da58b72d490ac6ff7e822278a816a73d9c7c50cf56c2e97f48009f3312b097
    HEAD_REF master
    PATCHES
        fix-runtime-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHJSON_ENABLE_INSTALL=ON
        -DHJSON_ENABLE_TEST=OFF
        -DHJSON_ENABLE_PERFTEST=OFF
        -DHJSON_VERSIONED_INSTALL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME hjson CONFIG_PATH lib/hjson)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
