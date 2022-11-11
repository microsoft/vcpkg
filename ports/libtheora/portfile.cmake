vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/theora
    REF fa5707d68c2a4338d58aa8b6afc95539ba89fecb
    SHA512 e33da23a17e93709dfe4421b512cedbd9aab0d706f5650e0436f9c8e1cde76b902c3338d46750bb86d83e1bceb111ee84e90df36fb59b5c2e7f7aee1610752b2
    HEAD_REF master
    PATCHES
        0001-fix-uwp.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libtheora.def" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-theora-config.cmake.in" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(THEORA_X86_OPT ON)
else()
    set(THEORA_X86_OPT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_X86=${THEORA_X86_OPT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/unofficial-theora")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/LICENSE")
