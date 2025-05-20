vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/samples
    REF 58dead450bdac418fc55dfc512b8411556f51c0e
    SHA512 a244364c3a58cb75709861cc8637dadeada0fbb4bc5fc52886a61d52623b3dab75ed5ccd73bed1a4384f66753fc3fd16e8cafde925fce760add084b4fffeca97
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/spimpl.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-spimpl-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/spimpl.h")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "[*]/.*" "*/" REGEX)

