# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adishavit/argh
    REF "v${VERSION}"
    SHA512 66073718ef1fc31fbd0feb9daf366a2e28c759de44fb1882dc46a6d10f7a44635ae1155882dff916f55c51fad88bedebdfe361418f7669fac241feead68f2b5b
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

set(CONFIG_PATH lib/cmake/argh)
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    set(CONFIG_PATH cmake)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH "${CONFIG_PATH}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
