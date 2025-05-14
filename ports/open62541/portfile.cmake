vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF v${VERSION}
    SHA512 d4ff1b2df1f7df7e2e62e988796cfcdf0ddce2ea0b78eaca666524ab341f522fc4ca4f180de2b50faa59e112026c1fa4d25e1aba4afe0b671cc2e2d47f7db2fe
    HEAD_REF master
)

# Manually fetch the required submodule
vcpkg_from_github(
    OUT_SOURCE_PATH MDNSD_SOURCE_PATH
    REPO Pro/mdnsd
    REF v0.8.4.1
    SHA512 0862e4663014406675cf271136d775b3f007337e099784c8542f59a8800691f05760bc2b7350857c43b4f4ba358b728f5e4d76f4d00e35cf349f6ba73af2a132
    HEAD_REF master
)

file(COPY "${MDNSD_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/deps/mdnsd")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        diagnostics UA_ENABLE_DIAGNOSTICS
        discovery UA_ENABLE_DISCOVERY
	discovery-multicast UA_ENABLE_DISCOVERY_MULTICAST
        historizing UA_ENABLE_HISTORIZING
        methodcalls UA_ENABLE_METHODCALLS
        subscriptions UA_ENABLE_SUBSCRIPTIONS
        subscriptions-events UA_ENABLE_SUBSCRIPTIONS_EVENTS
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

if("multithreading" IN_LIST FEATURES)
    set(OPEN62541_MULTITHREADING_OPTIONS -DUA_MULTITHREADING=100)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${OPEN62541_ENCRYPTION_OPTIONS}
        ${OPEN62541_MULTITHREADING_OPTIONS}
        "-DOPEN62541_VERSION=v${VERSION}"
        -DUA_ENABLE_DEBUG_SANITIZER=OFF
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
