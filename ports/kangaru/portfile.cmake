vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF "v${VERSION}"
    SHA512 03835b156d6da9239e316bfad07684b7f3197798c314f7d8f707e9e225795546887867c5af7fd8ae075b7143d2f160b0185d6be16146975c868dea99c7334129
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hashtypeid KANGARU_HASH_TYPE_ID
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKANGARU_EXPORT=OFF
        -DKANGARU_TEST=OFF
        -DKANGARU_REVERSE_DESTRUCTION=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kangaru)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

# Put the license file where vcpkg expects it
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
