vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "osqp/osqp"
    REF "v${VERSION}"
    SHA512 00ead2c476aca935202c2a02e5a0309efee6db65ec4e7c56f3597324a2f224a16502a34e7552cd5600c085d327c308317894718f9ac825ec669895ac19a45c41
    PATCHES osqp.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/osqp"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
