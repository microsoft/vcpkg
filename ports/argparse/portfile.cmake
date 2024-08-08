# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/argparse
    REF "v${VERSION}"
    SHA512 31e03b7de44e091614c1680e76988e0f7f5bdc6baf0262ed0583c6311d6d0611b7e30fa73b4522fd99d8ea81e74e5a74a91888135a1352d9ab08bf4a5467d32d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGPARSE_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
