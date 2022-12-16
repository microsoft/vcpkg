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
        mysql.patch
)

vcpkg_list(SET CONFIGURE_OPTIONS)
if("dl" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --enable-dl=dlfcn)
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --disable-dl)
endif()

if("gmp" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --with-gmp)
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --without-gmp)
endif()

if("mysql" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --enable-mysql)
else()
    vcpkg_list(APPEND CONFIGURE_OPTIONS --disable-mysql)
endif()

if("odbc" IN_LIST FEATURES)
    vcpkg_list(APPEND CONFIGURE_OPTIONS --enable-odbc)
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

if(DEFINED VCPKG_TARGET_IS_WINDOWS OR DEFINED VCPKG_TARGET_IS_UWP OR DEFINED VCPKG_TARGET_IS_MINGW)
    function(patch_config_h build_type_suffix)
        set(filename "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${build_type_suffix}/config.h")
        file(READ "${filename}" config_h_contents)
        string(APPEND config_h_contents "\n#define __WOE__ 1\n")
        string(REPLACE "libiodbc.so" "odbc32.dll" config_h_contents "${config_h_contents}")
        string(REPLACE "libodbc.so" "odbc32.dll" config_h_contents "${config_h_contents}")
        string(REPLACE "libmysqlclient.so" "libmysql.dll" config_h_contents "${config_h_contents}")
        file(WRITE "${filename}" "${config_h_contents}")
    endfunction()
    patch_config_h("dbg")
    patch_config_h("rel")
endif()

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES glpsol AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
