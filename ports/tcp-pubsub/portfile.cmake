vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/tcp_pubsub
    REF "v${VERSION}"
    SHA512 f89b9d9cdbd8e5787ac8923ec65cc2fc259e7d12269b1466a4c29657d8d466e39b95ec8b8483e975bf393f71b5c2d8f59cfd3d955e4e72d69716ec59fe0429af
    PATCHES
        "fix-package-config-file.patch"
        "use-ports-for-asio-and-recycle.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTCP_PUBSUB_BUILD_SAMPLES=OFF
        -DTCP_PUBSUB_BUILD_ECAL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME tcp_pubsub
    CONFIG_PATH lib/cmake/tcp_pubsub
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
