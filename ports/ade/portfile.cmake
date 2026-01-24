vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/ade
    REF "v${VERSION}"
    SHA512 0a27e2e3278c34b76cc437823fdcf73d597cb4866fc6fd13059da41138b23e0eaea0326782a46b86967d9174d3aa67bfc8bdc281724cb7d0a8329387d56b9635
    HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
