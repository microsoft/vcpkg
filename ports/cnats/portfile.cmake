vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nats-io/nats.c
    REF "v${VERSION}"
    SHA512 59820cb7a4cf6aa0e4bd01c6eb19217e43bd4eeb100a883cf5d58ec52ddf195aba5e6c57d4054a9fd18f13f6667ad0f5876c7a8e829a593cfc2e799bd2cbd8b1
    HEAD_REF main
    PATCHES
        fix-sodium-dep.patch
        fix_install_path.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

