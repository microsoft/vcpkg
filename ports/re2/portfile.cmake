include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/re2-2017-12-01)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/re2/archive/2017-12-01.zip"
    FILENAME "re2-2017-12-01.zip"
    SHA512 64e9b8673201fd3b0253acfd9fcb2985e88db69724e31a9c839d3b5cddfa1b91cf9e4fb70b12250fd4d6a7934a50550f6000627607227ed97bca329bfeb5bcc4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=1 -DBUILD_SHARED_LIBS=1 -DBUILD_TESTING=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
