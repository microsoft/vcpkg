vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hesphoros/UniConv
    REF "v${VERSION}"
    SHA512 e830ce3d10172dbce460677b09991fa2697d2301deb65b7ed0a5af92cd06ccb4f7b96f4ef354da1d7049f6ae79e3f982886f12e4e6909d332189a5fc132d25b1
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" UNICONV_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICONV_BUILD_SHARED=${UNICONV_BUILD_SHARED}
        -DUNICONV_BUILD_TESTS=OFF
        -DUNICONV_LIBICONV_SOURCE=SYSTEM
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME UniConv
    CONFIG_PATH lib/cmake/UniConv
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
