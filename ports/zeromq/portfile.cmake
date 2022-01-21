vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF a01d259db372bff5e049aa966da4efce7259af67 #2022-1-19
    SHA512 b237a02519ff204946042a0b5f51c443c8e6c3ceed973dd51fbde9adfd67c619577ecc42b66c39f5eeaecd21330f7d08a0350ad900f5264e4e18b0c34f82e9ce
    PATCHES fix-arm.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sodium          WITH_LIBSODIUM
        draft           ENABLE_DRAFTS
        websockets-sha1 ENABLE_WS
)

set(PLATFORM_OPTIONS)
if(VCPKG_TARGET_IS_MINGW)
    set(PLATFORM_OPTIONS "-DCMAKE_SYSTEM_VERSION=6.0")
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
        -DWITH_LIBSODIUM_STATIC=${BUILD_STATIC}
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
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
