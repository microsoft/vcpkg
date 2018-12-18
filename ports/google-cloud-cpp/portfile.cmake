if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GoogleCloudPlatform/google-cloud-cpp
    REF v0.4.0
    SHA512 2198a7e055c37c2a0d782e2226c2cfb4009e01c36783fe23a0a32b10c7800c1998fbaea17281cb831e7b58975d1bcdb1b2bfec0a5e4fd9d08f25299b96e8893a
    HEAD_REF master
    PATCHES include-protobuf.patch
)

set(GOOGLEAPIS_VERSION 6a3277c0656219174ff7c345f31fb20a90b30b97)
vcpkg_download_distfile(GOOGLEAPIS
    URLS "https://github.com/google/googleapis/archive/${GOOGLEAPIS_VERSION}.zip"
    FILENAME "googleapis-${GOOGLEAPIS_VERSION}.zip"
    SHA512 809b7cf0429df9867c8ab558857785e9d7d70aea033c6d588b60d29d2754001e9aea5fcdd8cae22fad8145226375bedbd1516d86af7d1e9731fffea331995ad9
)

file(REMOVE_RECURSE ${SOURCE_PATH}/third_party)
vcpkg_extract_source_archive(${GOOGLEAPIS} ${SOURCE_PATH}/third_party)
file(RENAME ${SOURCE_PATH}/third_party/googleapis-${GOOGLEAPIS_VERSION} ${SOURCE_PATH}/third_party/googleapis)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGOOGLE_CLOUD_CPP_DEPENDENCY_PROVIDER=vcpkg
        -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp RENAME copyright)

vcpkg_copy_pdbs()
