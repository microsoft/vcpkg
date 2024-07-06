vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF "v${VERSION}"
    SHA512 f4119b3fe5944be8f5bc35ccff8d7a93b0f4fa9f129bc97a7b96879a11b5b35bd714b41dd209267417e94c5fed45fd3a74b349f94424f4b90bde07d9694d1d7d
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nuspell)
vcpkg_fixup_pkgconfig(
    # nuspell.pc depends on icu-uc.pc which has -lm specified as private
    # library. Ignore this -lm, otherwise this function shows error
    # because it can't find this. -lm is part of glibc on Linux.
    SYSTEM_LIBRARIES m
)

if (BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES nuspell AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
