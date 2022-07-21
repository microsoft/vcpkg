vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/cocoyaxi
    REF 3fd22601de4d7a06548ca4d24ac36b4f82cde8c5 #v2.0.3
    SHA512 2b261458e81cc7488bc4d12335b623a750071082b949ffa638e09ca2263ebfab7f8dd83dcb7c6b0085046fda26b5a52992f8907afb39f8f9e74601479c2fb9a7
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libcurl    WITH_LIBCURL
        openssl    WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSTATIC_VS_CRT=${STATIC_CRT}
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
