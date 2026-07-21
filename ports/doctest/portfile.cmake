set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO doctest/doctest
    REF "v${VERSION}"
    SHA512 d7222ae62cf2ac0f858567af0e539bd34cef47827004f805261007943e8e02370fcf16cbf0302581766353bf28317dd280a885fdc775baaa3e519aa2cf2f2eca
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=OFF
        -DDOCTEST_WITH_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
