vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChristianPanov/lwlog
    REF "v${VERSION}"
    SHA512 46615bb9680d847614955c5c371fc1b7f0e2741e240469fb220a62eb64b4caad5161fc741e4ebe3af4c37bb7db413702203c3fa5e4365a5b69aee24401873de4
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME lwlog_lib CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
