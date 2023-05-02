vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://vic.crs4.it/vic/download/pkgs/sl-7.8.2-Source.tar.gz"
    FILENAME "sl-7.8.2-Source.tar.gz"
    SHA512 1391dac1474ddb47d0cf0eb7baeb7db68d6356c2116f732dd57b8a050739523282ded0643cc466640f2b22f25dd6bfced00ede4e041b7ff83754a99ae6725d7d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES include_functional.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
	OPTIONS
		-DSL_TEST=OFF
		-DSL_INSTALL_SLFIND_MODULE=OFF
	OPTIONS_DEBUG
        -DSL_TEST=OFF
        -DSL_INSTALL_SLFIND_MODULE=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
