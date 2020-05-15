vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF bdce8336364595d1a446957a6164c97363349a53 # v1.74
    SHA512 148c949a4d1a07832e97dbf4b3333b728f7207756a95db633daad83636790abe0a335797b2c5a27938453727de43f6abb9f5a5b41909f223ee735ddd1924eb3f
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bindings       IMGUI_COPY_BINDINGS # should only be copied once, at most
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_COPY_BINDINGS=OFF
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
