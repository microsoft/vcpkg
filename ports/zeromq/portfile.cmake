vcpkg_download_distfile(patch4310
    URLS "https://patch-diff.githubusercontent.com/raw/zeromq/libzmq/pull/4310.diff"
    FILENAME "zeromq-libzmq-4310.diff"
    SHA512 64e6d37ab843e5b9aa9e56ba7904423ce0a2c6b4101dbd86b7b8b22c52c384ed7ea9764f9e0a53be04e7ade09923ca95452104e9760b66ebc0ed3ffef08a75c5
)

vcpkg_download_distfile(patch4311
    URLS "https://patch-diff.githubusercontent.com/raw/zeromq/libzmq/pull/4311.diff"
    FILENAME "zeromq-libzmq-4311.diff"
    SHA512 2b04e0ce4743d27070ea832c45e2d8fa0091c755757937cfa2a2bb43283ee38dc9f27343989e1ad8c45fda8a3cfaa012250b0c581e2f0407938cbb61b2a21e63
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF v4.3.4
    SHA512 ad828b1ab5a87983285a6b44b08240816ed1c4e2c73306ab1a851bf80df1892b5e2f92064a49fbadc1f4c75043625ace77dd25b64d5d1c2a7d1d61cc916fba0b
    PATCHES 
        fix-arm.patch
        ${patch4310}
        ${patch4311}
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
