vcpkg_fail_port_install(ON_TARGET "Linux" "OSX")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.5/ast-9.2.5.tar.gz"
    FILENAME "ast-9.2.5.tar.gz"
    SHA512 2eee3df56ca49a9fbb6b103b26f41a63a7b77533bcc74bc4154b57567ee6da53d5c7ff1d38c4ad0ce330d9b902e35d40184fa9e985506c3dcbbb03071be65760
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}    
)

set(CONFIGURE_OPTIONS
    --without-fortran
    --with-external-cminpack
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
