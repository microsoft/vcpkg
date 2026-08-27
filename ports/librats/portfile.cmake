vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librats/librats
    REF "${VERSION}"
    SHA512 09c330972ffaeec5621d63b1a43598fbe40bb497b21eff0252392551943d7d7512fdd76d8da983eea80e487a8665cfc79f0d05248e5b63f9ce733349ed5d6079
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bindings         RATS_BINDINGS
        search-features  RATS_SEARCH_FEATURES
        storage          RATS_STORAGE
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" RATS_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RATS_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRATS_SHARED_LIBRARY=${RATS_SHARED}
        -DRATS_STATIC_LIBRARY=${RATS_STATIC}
        -DRATS_BUILD_TESTS=OFF
        -DRATS_BUILD_CLIENT=OFF
        -DRATS_BUILD_EXAMPLES=OFF
        -DRATS_INSTALL=ON
        -DRATS_VERSION_OVERRIDE=${VERSION}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rats CONFIG_PATH lib/cmake/rats)

# Headers only — drop debug copy and any binaries that landed under share/.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# librats is MIT, but it embeds adapted single-primitive crypto sources and, for
# Android API < 24, a getifaddrs() shim. Each keeps its own notice; see
# THIRD_PARTY_NOTICES.md upstream for provenance and the list of modifications.
vcpkg_install_copyright(
    COMMENT [[
librats is licensed under the MIT license. It additionally embeds adapted
third-party sources that carry their own notices, reproduced below:

  * src/librats/crypto/curve25519.*  curve25519-donna     BSD-3-Clause
  * src/librats/crypto/poly1305.*    poly1305-donna       MIT
  * src/librats/crypto/{chacha,sha256,sha512,blake2*}.*
                                   noise-c                MIT
  * 3rdparty/android/ifaddrs-*     ifaddrs-android        BSD-2-Clause AND
                                   (Android API < 24)     BSD-1-Clause
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/licenses/curve25519-donna.LICENSE"
        "${SOURCE_PATH}/licenses/poly1305-donna.LICENSE"
        "${SOURCE_PATH}/licenses/noise-c.LICENSE"
        "${SOURCE_PATH}/licenses/ifaddrs-android.LICENSE"
)
