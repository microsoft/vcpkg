vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF "v${VERSION}"
    SHA512 8a4ae6251e12ee641a432011da8360e08866ac005a5930d3a6278ce470d8b4a88afbd5538504274ca5e0bf053845efb41c834acaab83121d9d986a41f31ff718
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${DNNL_OPTIONS}
)
vcpkg_cmake_install()

# The port name and the find_package() name are different (onednn versus dnnl)
vcpkg_cmake_config_fixup(PACKAGE_NAME dnnl CONFIG_PATH lib/cmake/dnnl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc/dnnl/reference/html")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
