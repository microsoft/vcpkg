include(vcpkg_common_functions)

set(LIBSODIUM_VERSION 1.0.15)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsodium-${LIBSODIUM_VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH ${SOURCE_PATH}
    REPO jedisct1/libsodium
    REF ${LIBSODIUM_VERSION}
    SHA512 ec497cb0007597efaeae0aecaa7484d6dcc53367607ec3fd28a98c6209f0cdecd5a6f560c15badd3a69b8da7d63676b11fb395ef4ed4da9b80467dbdc5f65a72
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/libsodium.vcxproj
    RELEASE_CONFIGURATION ReleaseDLL
    DEBUG_CONFIGURATION DebugDLL
	)
else()
	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/libsodium.vcxproj
	)
endif()


file(INSTALL
  ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsodium
  RENAME copyright
)
