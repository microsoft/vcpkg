vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libical/libical
    REF "v${VERSION}"
    SHA512 c0cb6793a8a745252df33348d8e7476ad8ff85ac84a9fef75a8b694a488a944856d56e564ec8e75c0da547eb3ed29d78a6d79fc0a449ab57c7ef6f1f3d82a3c0
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
