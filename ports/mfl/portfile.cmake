vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-niel/mfl
    REF v0.0.1
    SHA512 fa3fe1f93b171541e676fd87a7c559718fcb9318074579c8f11c53e320da0e5047f041fa218c4b280666312d84938d62a410bae42a751abfd8e5b6d1afe187b6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mfl TARGET_PATH share/mfl)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mfl RENAME copyright)
