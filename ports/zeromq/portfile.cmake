vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF "v${VERSION}"
    SHA512 108d9c5fa761c111585c30f9c651ed92942dda0ac661155bca52cc7b6dbeb3d27b0dd994abde206eacfc3bc88d19ed24e45b291050c38469e34dca5f8c9a037d
    PATCHES 
        fix-arm.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sodium            WITH_LIBSODIUM
        draft             ENABLE_DRAFTS
        websockets        ENABLE_WS
        websockets-secure WITH_TLS
        curve             ENABLE_CURVE
)

set(PLATFORM_OPTIONS "")
if(VCPKG_TARGET_IS_MINGW)
    list(APPEND PLATFORM_OPTIONS "-DCMAKE_SYSTEM_VERSION=6.0" "-DZMQ_HAVE_IPC=0")
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
        CMAKE_REQUIRE_FIND_PACKAGE_GnuTLS
        WITH_LIBBSD
        WITH_PERF_TOOL
        WITH_TLS
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/zmq")

vcpkg_fixup_pkgconfig()
