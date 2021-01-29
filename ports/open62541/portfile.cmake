set(VERSION v1.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF 8ad84962e67987af91d7f746425d7b26be47a0cb # v1.1.2
    SHA512 7cca9458cdfbc386c0a7012373c91e9ab3a4876303db95a513f62cf26e751446bd73c0fa1f76e0821d2a47747bfb4612e8822389bc9002775636db8f8093f94c
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    openssl UA_ENABLE_ENCRYPTION_OPENSSL
    mbedtls UA_ENABLE_ENCRYPTION_MBEDTLS
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPEN62541_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/open62541/tools)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
