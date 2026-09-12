vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cpp_client_telemetry
    REF v${VERSION}
    SHA512 4a3cdb2f8d7664f6b003d8cb24190c7d98ad39c899d13e2ecf27af4f32b8820f5deecacd6377c7dafda698864a19f7beb9501372c2d1291b6a75f44a9cf832fc
    HEAD_REF main
)

# Determine if Apple HTTP should be used (no curl needed).
# Note: BUILD_APPLE_HTTP must remain ON for macOS/iOS because the vcpkg.json
# curl dependency is excluded on these platforms.
set(MATSDK_BUILD_APPLE_HTTP OFF)
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  set(MATSDK_BUILD_APPLE_HTTP ON)
endif()

# iOS build options
set(MATSDK_BUILD_IOS OFF)
if(VCPKG_TARGET_IS_IOS)
  set(MATSDK_BUILD_IOS ON)
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
        -DBUILD_IOS=${MATSDK_BUILD_IOS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MSTelemetry CONFIG_PATH lib/cmake/MSTelemetry)

# Remove duplicate headers and empty dirs
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
