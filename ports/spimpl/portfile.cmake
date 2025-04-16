vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/samples
    REF 58dead450bdac418fc55dfc512b8411556f51c0e
    SHA512 a244364c3a58cb75709861cc8637dadeada0fbb4bc5fc52886a61d52623b3dab75ed5ccd73bed1a4384f66753fc3fd16e8cafde925fce760add084b4fffeca97
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/spimplConfig.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/spimpl.h")

file(READ "${SOURCE_PATH}/spimpl.h" file_content)
string(REGEX REPLACE "\\*/.*" "*/" new_content "${file_content}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${new_content}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
