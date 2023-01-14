vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom
    REF 99ec1f99f2d175f07cc26e63082502ee62982dac # 3.1.0
    SHA512 64bd96c6b56c300b92e2bd6a875c4bc3c4c5d2ee332a75a8d98099aee0db3e9c33fa7d75fdc4d013e7b6ac47296f524ef713639b06e66035135dfc2a8cca0276
    HEAD_REF master
    PATCHES
        0001_use_math_defines.patch
        0005-fix-config-and-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES check_urdf urdf_mem_test urdf_to_graphiz urdf_to_graphviz AUTO_CLEAN)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/urdfdom/cmake)
    # Empty folders
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/urdfdom")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/urdfdom")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
