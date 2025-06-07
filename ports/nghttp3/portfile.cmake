vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/nghttp3
    REF v${VERSION}
    SHA512 d662f37db7794f2de0460bc46185aae7a35fbe230dbe9c94e54a471332ea9b75c369535f77e1749fff049a1d37e7b806f9c54f72233939073d0215e57b4d22fb
    HEAD_REF main
    PATCHES
)

vcpkg_from_github(
    OUT_SOURCE_PATH SFPARSE_SOURCE_PATH
    REPO ngtcp2/sfparse
    REF 7eaf5b651f67123edf2605391023ed2fd7e2ef16
    SHA512 f53bc23ec58dca15d65a0669438d52e5df276996aa850980aae05c7147dd6f6894079f1824629a6bb912c40eb4d905edb2658f69d20e8313eec0e0a69e46d3ab
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
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
