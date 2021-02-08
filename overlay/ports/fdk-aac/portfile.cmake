vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    he-aac HE_AAC
)

if(HE_AAC)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO mstorsjo/fdk-aac
        REF 77ee4dd31e8812a589e03f03347f592ef8260f4f
        SHA512 f7ade591dbfe2ee9e383955de13f5d1d122ed7bb3e52dd3b3b3b59af716f5057b099628b290a3b62ccef1539e66bcbb0ec7b7ca2ed0b57d8f30e575d2a1ba8a5
        HEAD_REF master
    )
else()
    vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL https://gitlab.freedesktop.org/Be/fdk-aac-stripped.git
        REF f6e49829e17892045de223fffbc9bd704c3be2be
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
