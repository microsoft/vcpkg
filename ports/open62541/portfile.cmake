set(VERSION v1.2.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF "${VERSION}"
    SHA512 ffcc697901ec978fb9d1f8996f8a4c5114c98a0ec19206cac95d1a84f8d0fcbe38bf73e88f1df59d53bc6be481102aa2f2a6a0efa29797e7ce11123bd23131c2
    HEAD_REF master
    PATCHES
        openssl.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl UA_ENABLE_ENCRYPTION_OPENSSL
        mbedtls UA_ENABLE_ENCRYPTION_MBEDTLS
        amalgamation UA_ENABLE_AMALGAMATION
        historizing UA_ENABLE_HISTORIZING
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPEN62541_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/open62541/tools")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
