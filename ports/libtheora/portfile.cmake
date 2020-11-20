vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/theora
    REF fa5707d68c2a4338d58aa8b6afc95539ba89fecb
    SHA512 e33da23a17e93709dfe4421b512cedbd9aab0d706f5650e0436f9c8e1cde76b902c3338d46750bb86d83e1bceb111ee84e90df36fb59b5c2e7f7aee1610752b2
    HEAD_REF master
    PATCHES
        0001-fix-uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libtheora.def DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-theora-config.cmake.in DESTINATION ${SOURCE_PATH})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(THEORA_X86_OPT ON)
else()
    set(THEORA_X86_OPT OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_X86=${THEORA_X86_OPT}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/unofficial-theora TARGET_PATH share/unofficial-theora)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtheora)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libtheora/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtheora/copyright)
