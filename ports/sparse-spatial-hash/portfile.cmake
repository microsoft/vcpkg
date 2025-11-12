vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO queelius/sparse_spatial_hash
    REF "v${VERSION}"
    SHA512 8823682871472527c4d7fee571cb5db64e7783f84d90eb8f58e4e2d96d22e14fcfce29c647e68606d91b41bc91f1cf095862917499ed66a907ab4737712669e7
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sparse_spatial_hash)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
