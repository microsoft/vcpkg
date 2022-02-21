
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nats-io/nats.c
    REF v3.2.0
    SHA512 570bbd5b6ed25db17755f4cbd2df9449bf1f838450e29aaa1483c11e6131293490d302031e3039d710bbbc3563ce72fb72cd3ad2c98618977a4858a5a3f2abe3
    HEAD_REF master
    PATCHES
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "streaming"  NATS_BUILD_STREAMING
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_SHARED=ON)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_STATIC=OFF)
    list(APPEND OPTIONS -DBUILD_TESTING=OFF)
else()
    list(APPEND OPTIONS -DNATS_BUILD_LIB_SHARED=OFF)
    list(APPEND OPTIONS -DNATS_BUILD_LIB_STATIC=ON)
    list(APPEND OPTIONS -DBUILD_TESTING=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        ${OPTIONS}
        -DNATS_BUILD_TLS_USE_OPENSSL_1_1_API=ON
        -DNATS_BUILD_USE_SODIUM=ON
        -DNATS_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

if(VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/nats.dll")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/nats.dll ${CURRENT_PACKAGES_DIR}/bin/nats.dll)
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/natsd.dll")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/natsd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/natsd.dll)
        endif()
    endif()
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


