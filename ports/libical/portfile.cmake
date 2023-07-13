vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF 5990fd0ac00ee3f068909ac86aa642c940720150 #v3.0.16
    SHA512 46e9330373e0c5ff4ffb658c2bd0a18cf082b539edf467323926c9b256122613b75190305f3365e52f26371bf51142c16dd40b8c18d2d13020e703b1d5d45042
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
