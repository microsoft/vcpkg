vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/nghttp3
    REF v${VERSION}
    SHA512 23d85a2abfa81433049d7b1b0440b5b04ae3515830db0347da335a30b93c8be8e25d2f73e198cdb9207e2b51ce924f133bab7314cde76d80f73c51c1fd1c36c4
    HEAD_REF main
    PATCHES
)

vcpkg_from_github(
    OUT_SOURCE_PATH SFPARSE_SOURCE_PATH
    REPO ngtcp2/sfparse
    REF f2046eaa1acba7c5467399b1e1e1f354d22d1f48
    SHA512 b3cbcce6d96dc731d21a67940a05c1603d43ee9766819e1d174ca93c7afc7fa6247aa818368cafbb31444e0198ab5bba45808772a3ca89e459f8d2c0ffae6f5d
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/lib/sfparse")
file(MAKE_DIRECTORY "${SOURCE_PATH}/lib")
file(RENAME "${SFPARSE_SOURCE_PATH}" "${SOURCE_PATH}/lib/sfparse")


string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ENABLE_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LIB_ONLY=ON
        -DBUILD_TESTING=OFF
        "-DENABLE_STATIC_CRT=${ENABLE_STATIC_CRT}"
        "-DENABLE_STATIC_LIB=${ENABLE_STATIC_LIB}"
        "-DENABLE_SHARED_LIB=${ENABLE_SHARED_LIB}"
    MAYBE_UNUSED_VARIABLES
        BUILD_TESTING
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/nghttp3")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/nghttp3/version.h" [[
]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/nghttp3/nghttp3.h"
    "#ifdef NGHTTP3_STATICLIB"
    "#if 1"
    )
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
