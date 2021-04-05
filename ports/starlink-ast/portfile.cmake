vcpkg_fail_port_install(MESSAGE "starlink-ast currently only supports Windows and Mac platforms" ON_TARGET "Linux" "OSX")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.3/ast-9.2.3.tar.gz"
    FILENAME "ast-9.2.3.tar.gz"
    SHA512 5cd19d153381a22f7a250189321b9914b52ec05e057b48aa735477e414c6b1b535135bfdd72049aaf1ed245b8b9ff2a8664b3fb1d374429d89bab786b491e74e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        "patch-use-exeetc-envar.patch"
        "patch-avoid-gcc-specifics.patch"
)


set(CONFIGURE_OPTIONS "CFLAGS=-DCMINPACK_NO_DLL --without-fortran --without-pthreads --without-yaml star_cv_cnf_trail_type=long star_cv_cnf_f2c_compatible=no")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-static --enable-shared")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static --disable-shared")
endif()

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16 perl)    
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    OPTIONS ${CONFIGURE_OPTIONS}
)


file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/starlink-ast RENAME copyright)