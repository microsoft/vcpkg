vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symisc/unqlite
    REF 5d951cd302c14cc6a4e7f8552b47f1e13a511d1d
    SHA512 4b6507a2188dbbf76231748f3a6e990fe687a2a5e2ee8cca3bfc80605e5dbcef3f3e85b032685aa5cf490442d2b570dab8a4b8eb88b97ed84022bf74602c2dfb
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "threads"     ENABLE_THREADS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()


if ("threads" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unqlite.h"
        "#define _UNQLITE_H_" [[
#define _UNQLITE_H_
#define UNQLITE_ENABLE_THREADS
]]
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
