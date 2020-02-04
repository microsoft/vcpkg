include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF v1.2.5
    SHA512 41abf4d7e49f82d0c627db45730ed4751f302758210a21d646037d6f7e1a04998aa590a7aae8e4726d1dcaec723fc9bb9d5f405c34620212b8da5d1b8c34bce8
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
