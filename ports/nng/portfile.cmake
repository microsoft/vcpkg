include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF v1.1.0
    SHA512 79f8d66cdf1d8f0f50f888edf59b46671ca7439d1da0f25e5f729bd1365b4bc2969c90a377bbd25c41f84eeb231d03fb0bc7c2d5435e3e55f4cf80ae62f9b934
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

# Put the licence file where vcpkg expects it
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/nng/copyright COPYONLY)

vcpkg_copy_pdbs()
