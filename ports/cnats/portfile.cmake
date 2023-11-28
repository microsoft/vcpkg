vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nats-io/nats.c
    REF 5d057f66f897279975f1c8eb61c1ccaaf1a7ae01 #v3.7.0
    SHA512 07d560ac2e1c043e6fb3d182cdec28ac080f9c85f9618198f9db52a53d4d95401c5992e7c9e5c7d7dd0979f919ebb21f0fbba26beb66905068b06e0f4e7cae38
    HEAD_REF main
    PATCHES
        fix-sodium-dep.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "streaming"  NATS_BUILD_STREAMING
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_SHARED=ON)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_STATIC=OFF)
    list(APPEND OPTIONS -DBUILD_TESTING=OFF)
    list(APPEND OPTIONS -DNATS_BUILD_USE_SODIUM=ON)
else()
    list(APPEND OPTIONS -DNATS_BUILD_LIB_SHARED=OFF)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_STATIC=ON)
    list(APPEND OPTIONS -DBUILD_TESTING=ON)
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND OPTIONS -DNATS_BUILD_USE_SODIUM=OFF)
    else()
        list(APPEND OPTIONS -DNATS_BUILD_USE_SODIUM=ON)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        ${OPTIONS}
        -DNATS_BUILD_TLS_USE_OPENSSL_1_1_API=ON
        -DNATS_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

if(VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/nats.dll")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/nats.dll" "${CURRENT_PACKAGES_DIR}/bin/nats.dll")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/natsd.dll")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/natsd.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/natsd.dll")
        endif()
    endif()
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

if(VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/cnats/cnats-config-debug.cmake")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/cnats/cnats-config-debug.cmake" 
                "\${_IMPORT_PREFIX}/debug/lib/natsd.dll" "\${_IMPORT_PREFIX}/debug/bin/natsd.dll")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/cnats/cnats-config-release.cmake")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/cnats/cnats-config-release.cmake" 
                "\${_IMPORT_PREFIX}/lib/nats.dll" "\${_IMPORT_PREFIX}/bin/nats.dll")
        endif()
    endif()
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

