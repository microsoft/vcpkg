vcpkg_fail_port_install(ON_TARGET "Linux" "OSX")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.4/ast-9.2.4.tar.gz"
    FILENAME "ast-9.2.4.tar.gz"
    SHA512 84e6f243e6d9d77328b73b97355feb3990307fb9c8f9b2f30344d71e2f5e63a849cdce0090ff5b7cc16028e12d68516c885b13d76db841072c9d1d06a7742a9e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}    
)

set(CONFIGURE_OPTIONS
    --without-fortran
    star_cv_cnf_trail_type=long
    star_cv_cnf_f2c_compatible=no
)

if ("yaml" IN_LIST FEATURES)
    list(APPEND CONFIGURE_OPTIONS --with-yaml)
else()
    list(APPEND CONFIGURE_OPTIONS --without-yaml)
endif()

if ("pthreads" IN_LIST FEATURES)
    list(APPEND CONFIGURE_OPTIONS --with-pthreads)
else()
    list(APPEND CONFIGURE_OPTIONS --without-pthreads)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    USE_WRAPPERS
    DETERMINE_BUILD_TRIPLET
    ADDITIONAL_MSYS_PACKAGES perl
    OPTIONS ${CONFIGURE_OPTIONS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
