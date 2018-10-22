include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.65
    SHA512  f68bbf84b781ea3e409beccb02b0bf8fe78d56e1ce7d8fce785f629758310ae75c9624ed62b2b6194e50f00cc7cc17f643191f4fbbad9236aa2e82a9ea4f6aac
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/imgui)

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/imgui/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright)
