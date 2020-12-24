vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF 32b12a311e1f490f0d5c629ce887edfbf18f2d2c # version 1.3.2
    SHA512 cd1b1906e5b99d9f04ce41d3d93c0841c45a571ed824c4d19428ce68fd53366e5ed90411d5958baaf9fa0ab412639dec7594a8ec1f64de4b41168932e3565125
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    mbedtls NNG_ENABLE_TLS
    tools NNG_ENABLE_NNGCAT
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNNG_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nng)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/include/nng/nng.h
    "defined(NNG_SHARED_LIB)"
    "0 /* defined(NNG_SHARED_LIB) */"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/nng/nng.h
        "!defined(NNG_STATIC_LIB)"
        "1 /* !defined(NNG_STATIC_LIB) */"
    )
else()
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/nng/nng.h
        "!defined(NNG_STATIC_LIB)"
        "0 /* !defined(NNG_STATIC_LIB) */"
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES nngcat AUTO_CLEAN)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
