#header-only library
include(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/args-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Taywee/args/archive/master.zip"
    FILENAME "args.zip"
    SHA512 81751bfc86e15db1e5f245baa7df0464027b22b577c9de359e22dc4fe1dd550acfb116801b47d88b56d61b69a640c55757206f6f84977ace2fb02742b60ff216
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/license ${CURRENT_PACKAGES_DIR}/share/args/copyright)

# Copy the args header files
file(INSTALL ${SOURCE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hxx")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/args-master/examples ${CURRENT_PACKAGES_DIR}/include/args-master/test)
vcpkg_copy_pdbs()
