include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.64
    SHA512  22bb2c0bbb85d2bb40663046cc4907c36ecdbd9a2148c241bda0ab92ef037cc60c225efb5729f2826893ffff031f6db8f4651768bc3616810218e185eac1b456
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
