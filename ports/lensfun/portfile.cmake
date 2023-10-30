#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lensfun/lensfun
    REF "v${VERSION}"
    SHA512 4db9a08d51ba50c7c2ff528d380bb28e34698b2bb5c40e5f3deeaa5544c888ac7e0f638bbc3f33a4f75dbb67e0425ca36ce6d8cd1d8c043a4173a2df47de08c6
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LENSFUN_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LENSFUN_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    tool    BUILD_LENSTOOL
    sse     BUILD_FOR_SSE
    sse2    BUILD_FOR_SSE2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${LENSFUN_STATIC_LIB}
        -DBUILD_WITH_MSVC_STATIC_RUNTIME=${LENSFUN_STATIC_CRT}
        -DSCN_TESTS=OFF
        -DBUILD_DOC=OFF
        -DINSTALL_PYTHON_MODULE=ON
        -DINSTALL_HELPER_SCRIPTS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/docs/gpl-3.0.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

file(INSTALL "${SOURCE_PATH}/docs/lgpl-3.0.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
