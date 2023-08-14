vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple-oss-distributions/mDNSResponder
    REF f783506af3836b39b83fc14115bc2728a49db4b2 #mDNSResponder-1557.140.5.0.1
    SHA512 f5954d3f8ef40790e14d17de4cd861fc7df6900e54affefb8282f080a0bfc8b4ac9d238f2faaea6bb3849b342836e45f3b2cb9361402f89fcdce3c627a2b9b4d
    HEAD_REF main
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
  SET(BUILD_ARCH "Win32")
ELSE()
  SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH mDNSResponder.sln
    PLATFORM ${BUILD_ARCH}
    TARGET dns-sd
)

file(INSTALL "${SOURCE_PATH}/mDNSShared/dns_sd.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
