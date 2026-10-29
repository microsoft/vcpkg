vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(
    CSTDINT_PATCH
    URLS https://github.com/ros/urdfdom/commit/4061dfa3c8b56a7affe042002aca9945441d1e93.patch?full_index=1
    SHA512 e04f5e8a400927a678282573ebe35752309ea1db32389744a91d5385f7540a4cacd4b00561380f5ce5130df3e155146965e4a4aa0e86442ee7eee045511fad0c
    FILENAME 4061dfa3c8b56a7affe042002aca9945441d1e93.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom
    REF ${VERSION}
    SHA512 6386954bc7883e82d9db7c785ae074b47ca31efb7cc2686101e7813768824bed5b46a774a1296453c39ff76673a9dc77305bb2ac96b86ecf93fab22062ef2258
    HEAD_REF master
    PATCHES
        0001_use_math_defines.patch
        0005-fix-config-and-install.patch
        0006-pc_file_for_windows.patch
        "${CSTDINT_PATCH}"
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
