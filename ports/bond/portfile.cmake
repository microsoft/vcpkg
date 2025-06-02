vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/bond
    REF  "${VERSION}"
    SHA512 b00e371686bbd8aca36d70ffb079a460323e9aecef7431d78018891d27c9af9fe0cad9f489b7e98b3c9ef9786192d75e72fe6835fb6933983ccb0ecf05bb99df
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(GBC_ARCHIVE
        URLS "https://github.com/microsoft/bond/releases/download/${VERSION}/gbc-${VERSION}-amd64.zip"
        FILENAME "gbc-${VERSION}-amd64.zip"
        SHA512 4CD92F0665E36CB718311A237DF80B8CD93BFE33971F6460B88A1B74E9E2237D6AEA146766D6AE92674E2DDBBB3245CEBB199FF5BA82163FE69781340E0479AE
    )

    # Clear the generator to prevent it from updating
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/tools/")
    # Extract the precompiled gbc
    vcpkg_extract_source_archive(extracted_tool_dir ARCHIVE "${GBC_ARCHIVE}" NO_REMOVE_ONE_LEVEL)
    file(RENAME "${extracted_tool_dir}" "${CURRENT_BUILDTREES_DIR}/tools")

    set(FETCHED_GBC_PATH "${CURRENT_BUILDTREES_DIR}/tools/gbc-${VERSION}-amd64.exe")
    if(NOT EXISTS "${FETCHED_GBC_PATH}")
        message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exist, but it doesn't.")
    endif()
else()
    # According to the readme on https://github.com/microsoft/bond/
    # The build needs a version of the Haskel Tool stack that is newer than some distros ship with.
    # For this reason the message is not guarded by checking to see if the tool is installed.
    message("\nA recent version of Haskell Tool Stack is required to build.\n  For information on how to install see https://docs.haskellstack.org/en/stable/README/\n")
endif()

set(ENV{STACK_ROOT} "${CURRENT_BUILDTREES_DIR}/stack")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBOND_LIBRARIES_ONLY=TRUE
        -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
        -DBOND_SKIP_GBC_TESTS=TRUE
        -DBOND_FIND_RAPIDJSON=TRUE
        -DBOND_SKIP_CORE_TESTS=TRUE
        -DBOND_STACK_OPTIONS=--allow-different-user
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/bond)

vcpkg_copy_pdbs()

cmake_path(NATIVE_PATH SOURCE_PATH native_source_path)
foreach(header bond_apply.h bond_const_apply.h bond_const_enum.h bond_const_reflection.h bond_const_types.h bond_enum.h bond_reflection.h bond_types.h)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bond/core/${header}" "${native_source_path}" "")
endforeach()

# There's no way to supress installation of the headers in the debug build,
# so we just delete them.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Put the license file where vcpkg expects it
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
