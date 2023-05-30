
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "ThrowTheSwitch/Unity"
    REF "v${VERSION}"
    SHA512 "ff280a62f2707fe05e33c631be5d1ed4f064a3fe032a9376b4fb7b83e01587fcfacfd5b4d22605a554d80ec7b554552fd9be39566a65285be73efe720bc8e9b7"
    HEAD_REF "master"
    PATCHES
        "include-dir.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fixture     UNITY_EXTENSION_FIXTURE
        memory      UNITY_EXTENSION_MEMORY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        "-DUNITY_EXTENSION_FIXTURE=${UNITY_EXTENSION_FIXTURE}"
        "-DUNITY_EXTENSION_MEMORY=${UNITY_EXTENSION_MEMORY}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unity)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
