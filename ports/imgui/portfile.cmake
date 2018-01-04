include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.53
    SHA512 3e1ebf3844eaca3471064fa3d5792525c696b39f502c75235fae469038b73ae0eff198f13d5e1a35f86c011903cd379066afe1e22b6df769b9b16dc390f8b0c3
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
