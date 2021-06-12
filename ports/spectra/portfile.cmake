vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yixuan/spectra
    REF ec27cfd2210a9b2322825c4cb8e5d47f014e1ac3 # v0.9.0
    SHA512 c383405faab851ab302ee1ccb78741c60ab250c05321eee65078f72769ced396b2c8b4a49442cb5836f659e27adbbc3b538198ee877495e49a980a185d49d420
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
