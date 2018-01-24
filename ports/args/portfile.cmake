#header-only library
include(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/args-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Taywee/args/archive/master.zip"
    FILENAME "args.zip"
    SHA512 0868ba13dec8be41bf849e61ae3286611bf70726f86dd34adf8a41f5f775ddeb41e57f2afbd0bb5e2a757b452384791077ee562c09155333bf14ec89154ee20d
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/license ${CURRENT_PACKAGES_DIR}/share/args/copyright)

# Copy the args header files
file(INSTALL ${SOURCE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hxx")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/args-master/examples ${CURRENT_PACKAGES_DIR}/include/args-master/test)
vcpkg_copy_pdbs()
