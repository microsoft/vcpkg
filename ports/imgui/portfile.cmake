vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.77
    SHA512 d5ebf4bb5e1ce83b226f2e68b3afe0f0abaeb55245fedf754e5453afd8d1df4dac8b5c47fc284c2588b40d05a55fc191b5e55c7be279c5e5e23f7c5b70150546
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bindings    IMGUI_COPY_BINDINGS # should only be copied once, at most
    freetype    IMGUI_FREETYPE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)