vcpkg_download_distfile(patch780
    URLS "https://patch-diff.githubusercontent.com/raw/ithewei/libhv/pull/780.diff?full_index=1"
    FILENAME "ithewei-libhv-780.diff"
    SHA512 8915aec64d31cc94b54002d6a0b6b9f69908cde7a24b6036900b24cb8111d6ef8bbaddf707289e54b2c4e4c782cdca9c619adfd11233bf56571e805529d488e6
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ithewei/libhv
    REF "v${VERSION}"
    SHA512 5b1b1552b31331279030c5f6ea087ee9ca3bb3911938bc6ce14c90297151adeb6e30f413eea9591092783e0e745e78e6b6f957e4a26fe0e3c050fdad08d470ad
    HEAD_REF master
    PATCHES
        "${patch780}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNITTEST=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libhv)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
