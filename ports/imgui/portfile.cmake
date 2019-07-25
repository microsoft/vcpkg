include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(sfml BUILD_WITH_SFML)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.70
    SHA512 b1a0fba339a9b19a49316494e58eabacd250e85e8ee17552c03ed99f50886072c882979039f18139e504c4406cf31aea3e9ce391d4641318f0022fa9b51bb9c4
    HEAD_REF master
)

if (BUILD_WITH_SFML)
    message(WARNING: " Please remove this port and install it again if you have built with sfml.")
    # Backup IMGUI source path
    set(IMGUI_DIR ${SOURCE_PATH})

    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO eliasdaler/imgui-sfml
        REF v2.0.2
        SHA512 44099e162c0e712ec9147452189649801a6463396830e117c7a0a4483d0526e94554498bfa41e9cd418d26286b5d1a28dd1c2d305c30d1eb266922767e53ab48
        HEAD_REF master
    )
    
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DBUILD_DOCUMENTATION=OFF
            -DENABLE_GTEST=OFF
            -DIMGUI_DIR=${IMGUI_DIR}
    )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ImGui-SFML)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    # Restore SOURCE_PATH to install copyright
    set(SOURCE_PATH ${IMGUI_DIR})
else()

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS_DEBUG
            -DIMGUI_SKIP_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets()
endif()

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright COPYONLY)
