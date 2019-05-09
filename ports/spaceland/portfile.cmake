include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sl-7.8.2-Source)

vcpkg_download_distfile(ARCHIVE
    URLS "http://vic.crs4.it/vic/download/pkgs/sl-7.8.2-Source.tar.gz"
    FILENAME "sl-7.8.2-Source.tar.gz"
    SHA512 1391dac1474ddb47d0cf0eb7baeb7db68d6356c2116f732dd57b8a050739523282ded0643cc466640f2b22f25dd6bfced00ede4e041b7ff83754a99ae6725d7d
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
	OPTIONS
		-DSL_TEST=OFF
		-DSL_INSTALL_SLFIND_MODULE=OFF
	OPTIONS_DEBUG
        -DSL_TEST=OFF
        -DSL_INSTALL_SLFIND_MODULE=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle license
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/spaceland)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spaceland/COPYING ${CURRENT_PACKAGES_DIR}/share/spaceland/license)

# Handle copyright
file(COPY ${SOURCE_PATH}/copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/spaceland)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spaceland/copyright.txt ${CURRENT_PACKAGES_DIR}/share/spaceland/copyright)
