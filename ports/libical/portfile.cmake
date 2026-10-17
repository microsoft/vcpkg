vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF "v${VERSION}"
    SHA512 406a0712a595b62a431b35eb72a984140848a8cdbe38cd5e371e96c37d7c2a4122df487e013146634855edca409dfad345d2370d1f37849aff80dddfb6aa832d
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "rscale"    CMAKE_DISABLE_FIND_PACKAGE_ICU
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS -DLIBICAL_STATIC=ON)
    list(APPEND FEATURE_OPTIONS -DLIBICAL_GOBJECT_INTROSPECTION=OFF)
else()
    list(APPEND FEATURE_OPTIONS -DLIBICAL_STATIC=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_BerkeleyDB=ON
        -DLIBICAL_ENABLE_BUILTIN_TZDATA=ON
        -DLIBICAL_GLIB=OFF
        -DLIBICAL_BUILD_DOCS=OFF
        -DLIBICAL_BUILD_TESTING=OFF
        -DLIBICAL_JAVA_BINDINGS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibIcal CONFIG_PATH CONFIG_PATH lib/cmake/LibIcal)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
