set(VERSION 2.6.0)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(RBDL_STATIC ON)
else()
    set(RBDL_STATIC OFF)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/rbdl/rbdl/archive/v2.6.0.tar.gz"
    FILENAME "rbdl260.tar.gz"
    SHA512 7b5fd03c0090277f295a28a1ff0542cd8cff76dda4379b3edc61ca3d868bf77d8b4882f81865fdffd0cf756c613fe55238b29a83bc163fc32aa94aa9d5781480
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    REF ${VERSION}
    # (Optional) Read the docs for how to generate patches at:
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    PATCHES
        001_x64_number_of_sections_exceeded_in_object_file_patch.diff
)

# # NOT READY YET, ONLY CORE --> TO-DO
# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
#     tbb   WITH_TBB
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
# )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DRBDL_BUILD_STATIC=${RBDL_STATIC}
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/rbdl.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/rbdl.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        endif()
    endif()
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/rbdl)

# # Moves all .cmake files from /debug/share/rbdl/ to /share/rbdl/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
vcpkg_fixup_cmake_targets()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/rbdl RENAME copyright)

# # Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

# # Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME rbdl MODULE)
