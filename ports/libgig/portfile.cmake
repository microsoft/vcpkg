vcpkg_download_distfile(ARCHIVE
    URLS "https://download.linuxsampler.org/packages/libgig-${VERSION}.tar.bz2"
    FILENAME "libgig-${VERSION}.tar.bz2"
    SHA512 7844d31acba4bd2f2a499511c3f45ec0a883336193a1422d6d0cd1a8d0c2e97f9f89230176969e5a80b483890914d424eb778338afd583197fdea8bee3c08627
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} dynamic LIBGIG_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools LIBGIG_BUILD_TOOLS
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
