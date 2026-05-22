vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO capnproto/capnproto
    REF "v${VERSION}"
    SHA512 6f31294ffe613b28ee891a7e7465d35781697dc7ed51f806b7c707c8fc94ead01099ab356041646e382320ff922f40c393b4b58f3106bbc3fb547386d7c0ed1a
    HEAD_REF master
    PATCHES
        undef-KJ_USE_EPOLL-for-ANDROID_PLATFORM-23.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # In ARM64 it fails without /bigobj
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /bigobj")
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} /bigobj")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "openssl" OPENSSL_FEATURE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        "-DWITH_OPENSSL=${OPENSSL_FEATURE}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CapnProto)

vcpkg_copy_tools(TOOL_NAMES capnp capnpc-c++ capnpc-capnp AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
