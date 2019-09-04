include(vcpkg_common_functions)

# Compile as static lib since vcpkg's imgui is compiled as static lib
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliasdaler/imgui-sfml
    REF v2.0.2
    SHA512 44099e162c0e712ec9147452189649801a6463396830e117c7a0a4483d0526e94554498bfa41e9cd418d26286b5d1a28dd1c2d305c30d1eb266922767e53ab48
    HEAD_REF master
    PATCHES
        static-build-with-vcpkg-imgui.patch
        remove-delegating-ctor.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ImGui-SFML)
vcpkg_copy_pdbs()

# Debug include directory not needed
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui-sfml RENAME copyright)
