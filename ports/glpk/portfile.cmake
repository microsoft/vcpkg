vcpkg_minimum_required(VERSION 2022-10-12)
set(DISTFILE_SHA512_HASH 4e92195fa058c707146f2690f3a38b46c33add948c852f67659ca005a6aa980bbf97be96528b0f8391690facb880ac2126cd60198c6c175e7f3f06cca7e29f9d)

vcpkg_download_distfile(
    DISTFILE
    FILENAME "glpk.tar.gz"
    URLS "https://ftpmirror.gnu.org/gnu/glpk/glpk-${VERSION}.tar.gz" "https://ftp.gnu.org/gnu/glpk/glpk-${VERSION}.tar.gz"
    SHA512 ${DISTFILE_SHA512_HASH}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${DISTFILE}"
    PATCHES
        configure.ac.patch
)

vcpkg_list(SET CONFIGURE_OPTIONS)
if("dl" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --enable-dl=dlfcn "LIBS=-ldl \$LIBS")
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --disable-dl)
endif()

if("gmp" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --with-gmp)
    string(APPEND requires " gmp")
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --without-gmp)
endif()

if("mysql" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS
        --enable-mysql
        "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include/mysql \$CPPFLAGS"
    )
    string(APPEND requires " mysql")
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --disable-mysql)
endif()

if("odbc" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --enable-odbc)
    string(APPEND requires " odbc")
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --disable-odbc)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    NO_ADDITIONAL_PATHS
    DETERMINE_BUILD_TRIPLET
    OPTIONS
        ${CONFIGURE_OPTIONS}
)

vcpkg_install_make()
set(libname glpk)
configure_file("${CMAKE_CURRENT_LIST_DIR}/glpk.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glpk.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
  configure_file("${CMAKE_CURRENT_LIST_DIR}/glpk.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glpk.pc" @ONLY)
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES glpsol AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
