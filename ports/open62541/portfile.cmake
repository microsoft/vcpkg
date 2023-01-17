
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF "v${VERSION}"
    SHA512 3230355237a3c88351ddd1d291057ab0b1e4ab0a3a1218c90a0201d4d77769098e6fbced26efef7c8635020b6d64748d065fc707615c45487aa3502aa19b6687
    HEAD_REF master
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
        -DUA_FORCE_WERROR=OFF
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
