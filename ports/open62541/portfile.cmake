vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF "v${VERSION}"
    SHA512 48ae61fd096c3a45f57ecc70bec9bb4223d046eed017532937c99883e4e92f79d7425b4db02c1a7e451764b787313efd76b2ae3cd3011d575154199d5350a790
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        amalgamation UA_ENABLE_AMALGAMATION
        historizing UA_ENABLE_HISTORIZING
)

if("openssl" IN_LIST FEATURES)
    set(OPEN62541_ENCRYPTION_OPTIONS -DUA_ENABLE_ENCRYPTION=OPENSSL)
    if("mbedtls" IN_LIST FEATURES)
        message(WARNING "Only one encryption method can be used. When both [openssl] and [mbedtls] "
            "are on, openssl is used. To use [mbedtls], don't enable [openssl]. To suppress this "
            "message, don't enable [mbedtls]")
    endif()
elseif("mbedtls" IN_LIST FEATURES)
    set(OPEN62541_ENCRYPTION_OPTIONS -DUA_ENABLE_ENCRYPTION=MBEDTLS)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${OPEN62541_ENCRYPTION_OPTIONS}
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
