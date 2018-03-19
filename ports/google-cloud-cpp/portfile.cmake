if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

set(GOOGLE_CLOUD_CPP_VERSION 0.1.0-pre1)
vcpkg_download_distfile(GOOGLE_CLOUD_CPP
    URLS "https://github.com/GoogleCloudPlatform/google-cloud-cpp/archive/v${GOOGLE_CLOUD_CPP_VERSION}.zip"
    FILENAME "gcpp-${GOOGLE_CLOUD_CPP_VERSION}.zip"
    SHA512 2c08818d4ce9712c5ecb7015ea88a6905ef05f55b8a3586e13b2167a5bb4b3c25488660324c05f1dc1f5c5953533c0bb319e209373fa509beeeff810be62fa54
)

set(GOOGLEAPIS_VERSION 92f10d7033c6fa36e1a5a369ab5aa8bafd564009)
vcpkg_download_distfile(GOOGLEAPIS
    URLS "https://github.com/google/googleapis/archive/92f10d7033c6fa36e1a5a369ab5aa8bafd564009.zip"
    FILENAME "googleapis-${GOOGLEAPIS_VERSION}.zip"
    SHA512 4280ece965a231f6a0bb3ea38a961d15babd9eac517f9b0d57e12f186481bbab6a27e4f0ee03ba3c587c9aa93d3c2e6c95f67f50365c65bb10594f0229279287
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src/google-cloud-cpp)
if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
endif()

vcpkg_extract_source_archive(${GOOGLE_CLOUD_CPP} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
file(RENAME ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src/google-cloud-cpp-${GOOGLE_CLOUD_CPP_VERSION} ${SOURCE_PATH})
vcpkg_extract_source_archive(${GOOGLEAPIS} ${SOURCE_PATH}/third_party)
file(REMOVE_RECURSE ${SOURCE_PATH}/third_party/googleapis)
file(RENAME ${SOURCE_PATH}/third_party/googleapis-${GOOGLEAPIS_VERSION} ${SOURCE_PATH}/third_party/googleapis)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGOOGLE_CLOUD_CPP_GRPC_PROVIDER=vcpkg
        -DGOOGLE_CLOUD_CPP_GMOCK_PROVIDER=vcpkg
)

# gRPC runs built executables during the build, so they need access to the installed DLLs.
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/bigtable/client/testing)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp RENAME copyright)

vcpkg_copy_pdbs()
