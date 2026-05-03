vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF "v${VERSION}"
    SHA512 1672702a0a875a5950e5d47c67c510ffa96225b11c461f697c7e3b05da1f1e591b05b931e0b41f69fe6c3b9ea8283db3bc1fcdfe89717c7fea26d5ddd4f7dcda
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDNNL_BUILD_DOC=OFF
        -DDNNL_BUILD_EXAMPLES=OFF
        -DDNNL_BUILD_TESTS=OFF
        ${DNNL_OPTIONS}
)
vcpkg_cmake_install()

# The port name and the find_package() name are different (onednn versus dnnl)
vcpkg_cmake_config_fixup(PACKAGE_NAME dnnl CONFIG_PATH lib/cmake/dnnl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
