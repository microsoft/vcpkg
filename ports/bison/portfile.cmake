set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(VCPKG_CROSSCOMPILING)
	message(FATAL_ERROR  "bison is a host-only port; please mark it as a host port in your dependencies.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/bison/bison-3.8.1.tar.gz"
    FILENAME "bison-3.8.1.tar.gz"
    SHA512 ac4e1ba999da707960ffbe7cada792e1a82147fc70c8738cf08c1e2e9098b9439d4506ebfa1c727541d217788896b38a6bc180b835b365e76eb6707fb5b5b148
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
      clang-fortify.patch # ported from https://git.savannah.gnu.org/cgit/gnulib.git/commit/?id=522aea1093a598246346b3e1c426505c344fe19a
      ffsl.patch
)

set(BUILD_OPTS --disable-yacc --disable-nls)
set(ENV{AUTOPOINT} true) # true, the program

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${BUILD_OPTS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
