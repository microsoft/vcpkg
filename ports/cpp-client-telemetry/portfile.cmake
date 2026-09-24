vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cpp_client_telemetry
    REF v${VERSION}
    SHA512 1ac75762c5069c5baf158768fd8e73aa055c545c6781c5f18ccd521d68244d7827cfec28ef826d4d413f5cb5b18f7c8adb1df43445d6fecd2afcfa4eddc6a891
    HEAD_REF main
)

# Determine if Apple HTTP should be used (no curl needed).
# Note: BUILD_APPLE_HTTP must remain ON for macOS/iOS because the vcpkg.json
# curl dependency is excluded on these platforms.
set(MATSDK_BUILD_APPLE_HTTP OFF)
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  set(MATSDK_BUILD_APPLE_HTTP ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMATSDK_BUILD_HEADERS=ON
        -DMATSDK_BUILD_LIBRARY=ON
        -DMATSDK_BUILD_TEST_TOOL=OFF
        -DMATSDK_BUILD_UNIT_TESTS=OFF
        -DMATSDK_BUILD_FUNC_TESTS=OFF
        -DMATSDK_BUILD_PRIVACYGUARD=OFF
        -DMATSDK_BUILD_CDS=OFF
        -DMATSDK_BUILD_LIVEEVENTINSPECTOR=OFF
        -DMATSDK_BUILD_SIGNALS=OFF
        -DMATSDK_BUILD_SANITIZER=OFF
        -DMATSDK_BUILD_AZMON=OFF
        -DMATSDK_BUILD_JNI_WRAPPER=OFF
        -DMATSDK_BUILD_OBJC_WRAPPER=OFF
        -DMATSDK_BUILD_SWIFT_WRAPPER=OFF
        -DMATSDK_BUILD_PACKAGE=OFF
        -DMATSDK_SQLITE_PROVIDER=SYSTEM
        -DMATSDK_ZLIB_PROVIDER=SYSTEM
        -DBUILD_VERSION=${VERSION}
        -DMATSDK_BUILD_APPLE_HTTP=${MATSDK_BUILD_APPLE_HTTP}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MSTelemetry CONFIG_PATH lib/cmake/MSTelemetry)

# Remove duplicate headers and empty dirs
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
