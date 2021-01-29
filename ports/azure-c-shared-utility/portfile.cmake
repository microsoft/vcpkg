vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 42574842914591aadc77701aac72f18cc72319ad
        SHA512 dfe6ccede4bebdb3a39fbfea1dc55ddca57cced0d2656ee4bed1a5e5c9c434e1f2d892eb4e29bbb424cb9a02f2374a95fb9a020442bea580d39c242efad1b789
        HEAD_REF master
        PATCHES 
            fix-utilityFunctions-conditions-preview.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 6f7bbcd23b39481dc0cf93185555d2513beea1ea
        SHA512 d1b77b155497e02f802e3f02d89ecbc4cb3d4507bc61f1feca8e6baad627e05e0f744dd5b4d0148a47021eb2308d9053d0fedbf95e40cff001250bca392fd5af
        HEAD_REF master
        PATCHES 
            fix-utilityFunctions-conditions.patch
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_c_shared_utility)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/configs/azure_iot_build_rules.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
