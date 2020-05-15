vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tishion/mmLoader
    REF 29e2263a68c17729058be0efb38f87f5ca6f6992
    SHA512 08bf5d51ede82fc3e2d19b6789891e17f6b370479cbfbe3be9858d8d7d0bc3c87236d052808b3ca3bb74b60a2d6a0c19cd61bda5e4e34e7a1ca25dba5f0c246e
    HEAD_REF master
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH MemModLoader.sln
    TARGET build\\mmLoader-static
    PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    LICENSE_SUBPATH License
    SKIP_CLEAN
)

# vcpkg_install_msbuild(INCLUDES_SUBPATH src) will install `src/mmLoader/mmLoader.c` as well.
file(INSTALL ${SOURCE_PATH}/src/mmLoader/mmLoader.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/mmLoader)

if("shellcode" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH MemModLoader.sln
        TARGET build\\mmLoader-shellcode-generator
        PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
        SKIP_CLEAN
    )

    get_filename_component(source_path_last_part ${SOURCE_PATH} NAME)

    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_last_part}/output/include/mmLoader/mmLoaderShellCode-${VCPKG_TARGET_ARCHITECTURE}-Debug.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/mmLoader)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_last_part}/output/include/mmLoader/mmLoaderShellCode-${VCPKG_TARGET_ARCHITECTURE}-Release.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/mmLoader)
endif()

vcpkg_clean_msbuild()
