
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openzim/libzim
    REF ${VERSION}
    SHA512 abcd5ef0e3f32cff0863c726a27cb42ad55522c17254f87e2bf6261ec564864017ea9136cb885d837a358f98ed123bf512551342703a7149cf93672f18e32db1
    HEAD_REF main
    PATCHES
        0001-build-share-library.patch

)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xapian     WITH_XAPIAN
)

set(EXTRA_OPTIONS "")

if(NOT WITH_XAPIAN)
    list(APPEND EXTRA_OPTIONS "-Dwith_xapian=false")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dexamples=false
      -Dstatic-linkage=false
      -Ddefault_library=shared
      ${EXTRA_OPTIONS}

)


vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
