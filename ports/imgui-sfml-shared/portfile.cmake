include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/imgui-sfml-shared
        REF 1.0
        SHA512 d6c1f218a84a400749b7e26aa79319c25c5d01026b95405d3d444845ca6bdff4e0885b714390ada95ee6d03609ca0ef6089a4c7b3afdf780b08b30ce18231169
        HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sfml-imgui)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui-sfml-shared)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/imgui-sfml-shared/LICENSE ${CURRENT_PACKAGES_DIR}/share/imgui-sfml-shared/copyright)
