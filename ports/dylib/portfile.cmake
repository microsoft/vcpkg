vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martin-olivier/dylib
    REF "v${VERSION}"
    SHA512 27de389778f431b9e473aa3a072e7232988748f445743ec4a7b9373d809b3f55be1a4d323bbca1cf76493d84f126de9d38cdb00c823702125b93498971cfc327
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME dylib CONFIG_PATH lib/CMakeLists.txt)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")