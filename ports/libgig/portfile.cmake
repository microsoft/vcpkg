vcpkg_download_distfile(ARCHIVE
    URLS "https://download.linuxsampler.org/packages/libgig-4.4.0.tar.bz2"
    FILENAME "libgig-4.4.0.tar.bz2"
    SHA512 0a3dcea4b13915a928bcd6b900142915eeaa308d3d66ee67b223fd74e0e7a4c9b078776eab791f24422ad2a091d603a48dd84711b4f621571965ec59b7326318
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-cpp20-msvc.diff
        fix-ssize_t-again.diff
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} dynamic LIBGIG_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extra-tools LIBGIG_BUILD_TOOLS
        tests LIBGIG_ENABLE_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBGIG_BUILD_SHARED=${LIBGIG_BUILD_SHARED}
)

vcpkg_cmake_install()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES dlsdump gigdump gigmerge korg2gig korgdump rifftree sf2dump
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin")
endif()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
