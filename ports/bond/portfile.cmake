vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BOND_VER 9.0.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/bond
    REF  ${BOND_VER}
    SHA512 b6bed9be8b5dd2a7d50c6bd275b94c62050b83717907522a07279cccc50e209306792c6f3c7f206afcb3226aed21b43b115b63dccc806eff5d9cd4e12b355461
    HEAD_REF master
    PATCHES fix-install-path.patch skip-grpc-compilation.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(GBC_ARCHIVE
    URLS "https://github.com/microsoft/bond/releases/download/${BOND_VER}/gbc-${BOND_VER}-amd64.zip"
    FILENAME "gbc-${BOND_VER}-amd64.zip"
    SHA512 f4480a3eb7adedfd3da554ef3cdc64b6e7da5c699bde0ccd86b2dd6a159ccacbb1df2b84b6bc80bc8475f30b904cba98085609e42aad929b2b23258eaff52048
    )

    # Clear the generator to prevent it from updating
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/tools/)
    # Extract the precompiled gbc
    vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
    set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc-${BOND_VER}-amd64.exe)

    if (NOT EXISTS "${FETCHED_GBC_PATH}")
        message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exists, but it doesn't.")
    endif()

else()
    # According to the readme on https://github.com/microsoft/bond/
    # The build needs a version of the Haskel Tool stack that is newer than some distros ship with.
    # For this reason the message is not guarded by checking to see if the tool is installed.
    message("\nA recent version of Haskell Tool Stack is required to build.\n  For information on how to install see https://docs.haskellstack.org/en/stable/README/\n")

endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
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
