vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 10030b2e17e851a1fd36206f125d8b34093b5de0b14b6538fb3006ac45b0f35841cbfd9afb788e357384a332f2445daaa84e96bb3f643f6aa7acc0a23687e018
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME faker-cxx
    CONFIG_PATH "lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSES.md")
