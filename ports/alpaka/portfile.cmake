vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alpaka-group/alpaka
    REF "${VERSION}"
    SHA512 1c507570f011575aa82e7ffa4dbaf8c1058fa65065dd711a9167cb36da5daef6090a8cad0dac429562d04bbd92a36bbcdd4f04a4a08bc3489e7d488813d43350
    HEAD_REF develop
)
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/alpaka")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
