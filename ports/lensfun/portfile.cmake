#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lensfun/lensfun
    REF "v${VERSION}"
    SHA512 4db9a08d51ba50c7c2ff528d380bb28e34698b2bb5c40e5f3deeaa5544c888ac7e0f638bbc3f33a4f75dbb67e0425ca36ce6d8cd1d8c043a4173a2df47de08c6
    HEAD_REF master
    PATCHES fix_build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LENSFUN_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LENSFUN_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    sse     BUILD_FOR_SSE
    sse2    BUILD_FOR_SSE2
)

set(LENSFUN_EXTRA_OPTS "")
if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND LENSFUN_EXTRA_OPTS -DPLATFORM_WINDOWS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${LENSFUN_EXTRA_OPTS}
        -DBUILD_STATIC=${LENSFUN_STATIC_LIB}
        -DBUILD_WITH_MSVC_STATIC_RUNTIME=${LENSFUN_STATIC_CRT}
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DINSTALL_PYTHON_MODULE=ON
        -DINSTALL_HELPER_SCRIPTS=OFF
        -DBUILD_LENSTOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if (LENSFUN_STATIC_LIB)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/gpl-3.0.txt" "${SOURCE_PATH}/docs/lgpl-3.0.txt")
