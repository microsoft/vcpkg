include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "@URL@"
    FILENAME "@FILENAME@"
    MD5 @MD5@
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/@ROOT_NAME@
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_cmake()
vcpkg_install_cmake()

# Handle copyright
#file(COPY ${CURRENT_BUILDTREES_DIR}/src/@ROOT_NAME@/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/@PORT@)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/@PORT@/LICENSE ${CURRENT_PACKAGES_DIR}/share/@PORT@/copyright)