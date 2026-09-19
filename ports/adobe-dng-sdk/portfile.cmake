vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://download.adobe.com/pub/adobe/dng/dng_sdk_1_7_1_2652_20260714.zip"
    FILENAME "dng_sdk_1_7_1_2652_20260714.zip"
    SHA512 95312197791f78dd307e57ca8ff19b6e611409cf49d8d9d8a9b337a35c6a90bf48fed424caca0b3b88e1883652940ec653071eb5e7cf0bce95a0b15c7c48df90
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        findnextfilew.patch
	missingincludes.patch
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CURRENT_PORT_DIR}/dngsdkConfig.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dng-validate    WITH_DNG_VALIDATE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME dngsdk)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST LICENSE.txt)

if("dng-validate" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES dng_validate AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# vcpkg complains with the following warning:
# 
# ...\portfile.cmake: warning: ${CURRENT_PACKAGES_DIR}/debug/include should not exist.
# To suppress this message, add set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)
# note: If this directory was created by a build system that does not allow
# installing headers in debug to be disabled, delete the duplicate directory
# with file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#
# I do not know how to disable the creation of this folder, so I used the
# suggestion to delete it manually.

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
