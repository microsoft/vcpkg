vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF "v${VERSION}"
    SHA512 1973fb0fd9c807b3bb4e9f49c792847741443e43035e83a79226ed041b8350ea8ca8855d2e204b5f3c9257d07ab853fd2077165731548dfd2e5521e36079db68
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
        -DBUILD_DOCS=OFF
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
