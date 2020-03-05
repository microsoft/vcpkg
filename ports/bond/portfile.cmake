include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/bond
    REF  8.2.0
    SHA512 b65d60be8a0fe2442c1d4f4d318b17dd2fb4e3456d97666719e52edaac8eb9ab967aeec30fabe5c32d375b604dec759a859f198ad769c12012e6c11617aa7211
    HEAD_REF master
    PATCHES fix-install-path.patch skip-grpc-compilation.patch
)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_download_distfile(GBC_ARCHIVE
    URLS "https://github.com/microsoft/bond/releases/download/8.2.0/gbc-8.2.0-amd64.zip"
    FILENAME "gbc-8.2.0-amd64.zip"
    SHA512 77a0e2dc7fcc476b599b9a9e70350bb5bb3ec6200d7dae224a58b5fdd308f2650a4291f72407701064a80536db042f6c00c203b9e83643b53f9768101988e8e4
    )

    # Extract the precompiled gbc
    vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
    set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc.exe)

    if (NOT EXISTS "${FETCHED_GBC_PATH}")
        message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exists, but it doesn't.")
    endif()

else()
    # According to the readme on https://github.com/microsoft/bond/
    # The build needs a version of the Haskel Tool stack that is newer than some distros ship with.
    # For this reason the message is not guarded by checking to see if the tool is installed.
    message("\nA recent version of Haskell Tool Stack is required to build.\n  For information on how to install see https://docs.haskellstack.org/en/stable/README/\n")

endif()

if ("bond-over-grpc" IN_LIST FEATURES)
    set(ENABLE_GRPC TRUE)
else()
    set(ENABLE_GRPC FALSE)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBOND_LIBRARIES_ONLY=TRUE
    -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
    -DBOND_SKIP_GBC_TESTS=TRUE
    -DBOND_ENABLE_COMM=FALSE
    -DBOND_ENABLE_GRPC=${ENABLE_GRPC}
    -DBOND_FIND_RAPIDJSON=TRUE
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/bond TARGET_PATH share/bond)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bond)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bond/LICENSE ${CURRENT_PACKAGES_DIR}/share/bond/copyright)

# There's no way to supress installation of the headers in the debug build,
# so we just delete them.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
