vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF ce6d48c578a08770fb171486750300fd534d0254
    SHA512 e204db3e40d99df2206f9537bf7dbc9bb8994174f4f9c4770dcc7a92622e6ff0e2b1be537d7fff96cfbdb0cdd0174bfd11ba60d08c4bab0ccb4db3ec25c06593
    PATCHES 
        fix-arm.patch
        include-dir-gnutls.patch # from https://github.com/zeromq/libzmq/pull/4533
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sodium          WITH_LIBSODIUM
        draft           ENABLE_DRAFTS
        websockets      ENABLE_WS
        websockets-secure WITH_TLS
)

set(PLATFORM_OPTIONS "")
if(VCPKG_TARGET_IS_MINGW)
    set(PLATFORM_OPTIONS -DCMAKE_SYSTEM_VERSION=6.0 -DZMQ_HAVE_IPC=0)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZMQ_BUILD_TESTS=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        -DWITH_PERF_TOOL=OFF
        -DWITH_DOCS=OFF
        -DWITH_NSS=OFF
        -DWITH_LIBBSD=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_GnuTLS=ON
        -DWITH_LIBSODIUM_STATIC=${BUILD_STATIC}
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    MAYBE_UNUSED_VARIABLES
        USE_PERF_TOOLS
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ZeroMQ)
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/zmq/COPYING.LESSER.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/zmq")

vcpkg_fixup_pkgconfig()
