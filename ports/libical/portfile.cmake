vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF "v${VERSION}"
    SHA512 53ecf6c14a68d569dd11bfdeb1a072def847a14d189c6af16eab202e004350ee7d9488c6b63e9cb67889e8c2dec90643fef46aec143a915f28270d0752eaa9d5
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "rscale"    CMAKE_DISABLE_FIND_PACKAGE_ICU
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS -DSTATIC_ONLY=ON)
else()
    list(APPEND FEATURE_OPTIONS -DSHARED_ONLY=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_BerkeleyDB=ON
        -DUSE_BUILTIN_TZDATA=ON
        -DICAL_GLIB=OFF
        -DICAL_BUILD_DOCS=OFF
        -DLIBICAL_BUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibIcal CONFIG_PATH CONFIG_PATH lib/cmake/LibIcal)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
