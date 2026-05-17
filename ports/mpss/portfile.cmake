# Android only supports shared libraries.
if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/mpss
    REF "v${VERSION}"
    SHA512 892052999aa045af768cfb708a4dc5de1ecc59f0e065ba8ab9331834cf19a8abb2cfac66a85b9c38abb9fb97cb506b1248b52f67647b257aa9e86240b0797213
    HEAD_REF main
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(LIBRARY_LINKAGE "STATIC")
    set(UNUSED_LINKAGE "SHARED")
else()
    set(LIBRARY_LINKAGE "SHARED")
    set(UNUSED_LINKAGE "STATIC")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl    MPSS_BUILD_MPSS_OPENSSL_${LIBRARY_LINKAGE}
        yubikey    MPSS_BACKEND_YUBIKEY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMPSS_BUILD_MPSS_CORE_${LIBRARY_LINKAGE}=ON
        -DMPSS_BUILD_MPSS_CORE_${UNUSED_LINKAGE}=OFF
        -DMPSS_BUILD_MPSS_OPENSSL_${UNUSED_LINKAGE}=OFF
        -DMPSS_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/mpss")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
