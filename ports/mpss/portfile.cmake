vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mpss
    REF "v${VERSION}"
    SHA512 71bea61ca1be310d2de9d2d2a98477cd54d12f83eb5746b3291ee7a9aeadf355d72e3bd619c9a72588a3ca81ee6dc3d1fad519845ccb36ab215a42bbd7ad0675
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
        openssl         MPSS_BUILD_MPSS_OPENSSL_${LIBRARY_LINKAGE}
        serialization   MPSS_WITH_SERIALIZATION
        yubikey         MPSS_BACKEND_YUBIKEY
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
