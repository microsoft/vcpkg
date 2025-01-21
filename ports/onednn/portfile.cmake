vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF "v${VERSION}"
    SHA512 251da59164c102a6dd3c97e92aef58a879930c0def6e9fe6e43e68e1316ed0c9844796e69eecebbde12085900bfcda6c1ab30db6df24ba9826883171c87a964d
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${DNNL_OPTIONS}
        -DDNNL_BUILD_DOC=OFF
        -DDNNL_BUILD_EXAMPLES=OFF
        -DDNNL_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

# The port name and the find_package() name are different (onednn versus dnnl)
vcpkg_cmake_config_fixup(PACKAGE_NAME dnnl CONFIG_PATH lib/cmake/dnnl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
