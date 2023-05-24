vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v5.1.2
    SHA512 138212ae5340836f0bc85d9d5327dc43ffdb1481ca72678b4619938b86c4c8e7c156eec1446f459636460a9015cd476031ad53d0979325e637ed97c19e2f87c8
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
