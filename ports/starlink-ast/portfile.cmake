vcpkg_fail_port_install(ON_TARGET "Linux" "OSX")

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

set(CONFIGURE_OPTIONS "--disable-shared --without-fortran star_cv_cnf_trail_type=long star_cv_cnf_f2c_compatible=no")

if ("yaml" IN_LIST FEATURES)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --with-yaml")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --without-yaml")
endif()

if ("pthreads" IN_LIST FEATURES)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --with-pthreads")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --without-pthreads")
endif()


set(CONFIGURE_OPTIONS_DEBUG " CFLAGS='-DCMINPACK_NO_DLL -O0 -g ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG}'")
set(CONFIGURE_OPTIONS_RELEASE " CFLAGS='-DCMINPACK_NO_DLL -O2 ${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE}'")

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=x86_64-w64-mingw32")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=i686-w64-mingw32")
endif()

vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16 perl)    
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    OPTIONS ${CONFIGURE_OPTIONS}
    OPTIONS_RELEASE ${CONFIGURE_OPTIONS_RELEASE}
    OPTIONS_DEBUG ${CONFIGURE_OPTIONS_DEBUG}
)

file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)