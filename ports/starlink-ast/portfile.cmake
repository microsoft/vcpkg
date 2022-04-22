vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.7/ast-9.2.7.tar.gz"
    FILENAME "ast-9.2.7.tar.gz"
    SHA512 4778658fe6b08af29b51807e2d988f8425d99d630a14d8fef9ca4ea43016d676df419a93c4b2fdecc0549c28c0665f61e366bd4e7aa896ebb8e47f56d5af1887
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
