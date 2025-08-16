vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexbor/lexbor
    REF v${VERSION}
    SHA512 86d798bb658a5bafd3ca6df6460c3f70ae53c91bf67d1018d4b1fc0649790bc13b490cbc5ea94b28a83860093cfb7142f3c5e1a136449892080825391ede5537
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        perf  LEXBOR_WITH_PERF
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DLEXBOR_BUILD_SHARED=${BUILD_SHARED}
    -DLEXBOR_BUILD_STATIC=${BUILD_STATIC}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/lexbor/html/tree/insertion_mode"
    "${CURRENT_PACKAGES_DIR}/debug/include/lexbor/html/tree/insertion_mode"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
