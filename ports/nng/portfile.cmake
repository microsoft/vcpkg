vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF 6ec4107907552db927be8601aed97b5a4b83d33d#version 1.3.0
    SHA512 28b99d822d7be0348d4e367c2d92cd2bd4a5563806454388ad3c7d9817ef91fa7b4408d15ce4c77ac6a8ad2dd7db173899fdaf7881585282bf57f4c487909be6
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NNG_STATIC_LIB)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    mbedtls NNG_ENABLE_TLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
        -DNNG_STATIC_LIB=${NNG_STATIC_LIB}
        -DNNG_TESTS=OFF
        -DNNG_ENABLE_NNGCAT=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
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

# Put the licence file where vcpkg expects it
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
