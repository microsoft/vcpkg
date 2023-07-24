vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF "v${VERSION}"
    SHA512 3e3eef21432fe88bc4dd9940ccad0308fdea3537b06fa5ac0e74c1bde53413dff29c8b3fc617a8a42b9ce88fcf213311d338a31b1ce73b3729342c9e68f06c78
    HEAD_REF dev
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES xxhsum XXHASH_BUILD_XXHSUM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake_unofficial"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xxHash)

if("xxhsum" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xxhsum AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
