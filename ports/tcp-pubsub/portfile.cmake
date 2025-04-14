vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/tcp_pubsub
    REF "v${VERSION}"
    SHA512 f8dfe5d506449c641fdb1876cbee144ca72a96fc829f2294c51a46ed2b3b0987356b36356ce43d44360ee36546f9e2af584631ddc851b89c9e9a22ced6d55f74
    PATCHES
        fix-finding-asio-recycle-deps.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTCP_PUBSUB_BUILD_SAMPLES=OFF
        -DTCP_PUBSUB_BUILD_ECAL_SAMPLES=OFF
	-DTCP_PUBSUB_USE_BUILTIN_RECYCLE=OFF # A bit confusing, this means to use recycle that is installed on the system
	-DTCP_PUBSUB_USE_BUILTIN_ASIO=OFF # A bit confusing, this means to use asio that is installed on the system
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME tcp_pubsub
    CONFIG_PATH lib/cmake/tcp_pubsub
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
