include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanomsg/nng
    REF ce9f0cb155ad0e97cfc7703d9d7c8e5bec3201bc
    SHA512 e1fca685e3397398bd259d126560902e813d1e2fb5cdb04de9d3f2fd74961f53af53dbaf9a555113a5588f07a3859d16bdc64f0a0ff65a7b5cf89965e764e68d
    HEAD_REF master
    PATCHES fix-include-path.patch
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
if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/nng)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nng)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(COPY
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/nng)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/share/nng/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/share/nng/copyright)

vcpkg_copy_pdbs()
