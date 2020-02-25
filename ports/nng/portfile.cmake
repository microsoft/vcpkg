vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF 53ae1a5ab37fdfc9ad5c236df3eaf4dd63f0fee9
    SHA512 f5532c0b0287df52ddae173dc92eff06d1f4b2b42a2f7afaf28a7736bf70618ae29ccd51fb9743795a8004918a2a2f55233e6ced58829561c745eafa6118b762
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
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
