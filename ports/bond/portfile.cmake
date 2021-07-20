vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BOND_VER 9.0.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/bond
    REF  ${BOND_VER}
    SHA512 3a7884eb00e6d0ab40c688f4a40cb2d3f356c48b38d48a9a08c756047a94b82619ef345483f42c3240732f5da06816b65a61acb83bfebb3c2c6b44099ce71bf9
    HEAD_REF master
    PATCHES fix-install-path.patch skip-grpc-compilation.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(GBC_ARCHIVE
        URLS "https://github.com/microsoft/bond/releases/download/${BOND_VER}/gbc-${BOND_VER}-amd64.zip"
        FILENAME "gbc-${BOND_VER}-amd64.zip"
        SHA512 41a4e01a9a0f6246a3c07f516f2c0cfc8a837eff2166c2bb787877e409d6f55eeb6084e63aabc3502492775a3fa7e381bf37fde0bdfced50a9d0b39dfaca7dfd
    )

    # Clear the generator to prevent it from updating
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/tools/)
    # Extract the precompiled gbc
    vcpkg_extract_source_archive(extracted_tool_dir ARCHIVE "${GBC_ARCHIVE}" NO_REMOVE_ONE_LEVEL)
    file(RENAME "${extracted_tool_dir}" "${CURRENT_BUILDTREES_DIR}/tools")

    set(FETCHED_GBC_PATH "${CURRENT_BUILDTREES_DIR}/tools/gbc-${BOND_VER}-amd64.exe")
    if(NOT EXISTS "${FETCHED_GBC_PATH}")
        message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exist, but it doesn't.")
    endif()
else()
    # According to the readme on https://github.com/microsoft/bond/
    # The build needs a version of the Haskel Tool stack that is newer than some distros ship with.
    # For this reason the message is not guarded by checking to see if the tool is installed.
    message("\nA recent version of Haskell Tool Stack is required to build.\n  For information on how to install see https://docs.haskellstack.org/en/stable/README/\n")

endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bond-over-grpc BOND_ENABLE_GRPC
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBOND_LIBRARIES_ONLY=TRUE
        -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
        -DBOND_SKIP_GBC_TESTS=TRUE
        -DBOND_ENABLE_COMM=FALSE
        -DBOND_FIND_RAPIDJSON=TRUE
        -DBOND_STACK_OPTIONS=--allow-different-user
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/bond TARGET_PATH share/bond)

vcpkg_copy_pdbs()

# There's no way to supress installation of the headers in the debug build,
# so we just delete them.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Put the license file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
