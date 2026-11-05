vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF "v${VERSION}"
    SHA512 1585ae3f3feded2492e43f4dd5dd43183329c57ffe92afa907f71eb26deaf34beab4434458a2d87e8795a4226339c5b0b493bd8a9186bb6f0c752fa1fdef10e3
    HEAD_REF dev
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES xxhsum XXHASH_BUILD_XXHSUM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build/cmake"
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

set(LICENSE_FILES "${SOURCE_PATH}/LICENSE")
if("xxhsum" IN_LIST FEATURES)
    list(APPEND LICENSE_FILES "${SOURCE_PATH}/cli/COPYING")
endif()
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
