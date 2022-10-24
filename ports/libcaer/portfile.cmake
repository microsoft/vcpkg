vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/libcaer
    REF 933dfa60a138091afb03014f8c24183bab7bba4e
    SHA512 6e74e308833ca3c923b318a42bab30edb04f763cdd5b243701416b72278d7315fdd8a62ebb87b704212507f76c3e45bc9728df17ea2d1eab5133dfcf550c8c35
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DENABLE_OPENCV=ON
        -DEXAMPLES_INSTALL=OFF
        -DBUILD_CONFIG_VCPKG=ON
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "libcaer" CONFIG_PATH "share/libcaer")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
