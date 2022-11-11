vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF 58be3660fb57c4c4a3d306730e849237d1271572 #2.6.1
    SHA512 8fc51655d0ecdb5b137d04c6b3ee01959d9505e0d7ee74cab872447b5873f214d38db55edf4040a56d4455557ec2c0707097337c6e276dbaf1c9c6e48b95a820
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

# Copyright and license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
