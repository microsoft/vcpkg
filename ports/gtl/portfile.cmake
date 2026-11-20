set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/gtl
    REF "v${VERSION}"
    SHA512 565cbb88009c926e309d111051edeeba1972e0cb43ee421d285965cdd5a1f2fe1b9283e5d555a10175323ec9782f59bbbcac134370e829eb845289f13083efb9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTL_BUILD_TESTS=OFF
        -DGTL_BUILD_EXAMPLES=OFF
        -DGTL_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/gtl")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/NOTICE"
    "${SOURCE_PATH}/licenses/license_blackbird"
    "${SOURCE_PATH}/licenses/license_boost"
    "${SOURCE_PATH}/licenses/license_folly"
    "${SOURCE_PATH}/licenses/license_lamerman"
    "${SOURCE_PATH}/licenses/license_mark_liu"
)
