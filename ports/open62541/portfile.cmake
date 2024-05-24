vcpkg_download_distfile(PATCH_6501
    URLS https://github.com/open62541/open62541/commit/14c1d6fb1175257b624bcd509817887f5e8a2543.patch?full_index=1
    SHA512 c7ae62bbab66bdb306b7aded3bd0fc3d63ccc082528475151d1ffecb743a34227a2694294d5f8d17949a24f87d853337c948fcc995a2da4b85c198c4ed47ab4d
    FILENAME 14c1d6fb1175257b624bcd509817887f5e8a2543.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF "v${VERSION}"
    SHA512 e0a2f9e748ee1b27b0bd400d56b6e90602d545c7a5c794ba9a1ccd1ab15bde3c2908440ec1662b4a6980b9e7ffcf532018f8894821405f8edbd5f0168ca4ccf3
    HEAD_REF master
    PATCHES
        "${PATCH_6501}"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(doc)" "")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "include(linting_target)" "")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
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
        "-DOPEN62541_VERSION=v${VERSION}"
        -DUA_MSVC_FORCE_STATIC_CRT=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/open62541")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/open62541/tools")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
