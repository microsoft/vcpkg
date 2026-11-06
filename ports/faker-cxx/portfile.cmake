vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 7996116664f05af95c91afc8ffb42d8610580e76572d089843fabbbf3756e0db6abf3ebca2b950e5ee29f40b30355a6a7d2c68ac4d0cdbffc953e0d392864e32
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFAKER_BUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME faker-cxx
    CONFIG_PATH "lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSES.md"
        "${SOURCE_PATH}/src/modules/ulid_struct.h"
)
