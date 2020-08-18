vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliasdaler/imgui-sfml
    REF v2.1
    SHA512 134c49e9c57bc4d3882d99a52ec87f74c11d2f3134501c79b20bce4612f315f2e3f33a521597b387ca8f91942cf2b82ec9f4a8b1672a700e7233a9758897b6d0
    HEAD_REF master
    PATCHES
        0001-fix_find_package.patch
        0002-fix_imgui_config.patch
        0003-fix_osx.patch
        004-fix-find-sfml.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    file(GLOB SFML_DYNAMIC_LIBS "${CURRENT_INSTALLED_DIR}/bin/sfml-*")
else()
    file(GLOB SFML_DYNAMIC_LIBS "${CURRENT_INSTALLED_DIR}/bin/libsfml-*")
endif()

if (SFML_DYNAMIC_LIBS)
    set(SFML_STATIC OFF)
else()
    set(SFML_STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSFML_STATIC_LIBRARIES=${SFML_STATIC}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ImGui-SFML)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
