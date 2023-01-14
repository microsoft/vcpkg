vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/libcaer
    REF 933dfa60a138091afb03014f8c24183bab7bba4e
    SHA512 f3ac74bb4cfc4077e5a226307f66a9b8b263201d2342d9e61ee98a23f95e7897895da9f148b4e910535779f779a26f5c192925386a99a70e9d22540a5421d646
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
