include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF ddeac617c9914284038241870cb99ae174fb3755
    SHA512 c45f322dfa3fba42db0561d95546159cc5e0768345d27f0bee53bdb71e77d5892e2e9bea50a625094ebf3c67b0c3fe0a8edea2660ebcb4fd0991fb0602055bc1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NNG_STATIC_LIB)

if("mbedtls" IN_LIST FEATURES)
    set(NNG_ENABLE_TLS ON)
else()
    set(NNG_ENABLE_TLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
        -DNNG_STATIC_LIB=${NNG_STATIC_LIB}
        -DNNG_TESTS=OFF
        -DNNG_ENABLE_NNGCAT=OFF
        -DNNG_ENABLE_TLS=${NNG_ENABLE_TLS}
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
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/nng/copyright COPYONLY)

vcpkg_copy_pdbs()
