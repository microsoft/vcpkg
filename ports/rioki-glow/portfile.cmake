vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/glow
    REF v0.2.0
    SHA512 ff81b56ce8bbceb5119c5cf48764cc1978bb0d3c4cddccc85ef0d3f7c85188c1dab53e083e09509d6ca96e4ac30ba277fc6915ba9ae388422c35cc8cd08c3978
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "rioki_glow")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
