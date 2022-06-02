set(CPPWINRT_VERSION 2.0.220418.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Windows.CppWinRT/${CPPWINRT_VERSION}"
    FILENAME "cppwinrt.${CPPWINRT_VERSION}.zip"
    SHA512 67738587f7b1ca98a7c2c2c0733dd09612deb5ef6bcfa788ca0bcccbbfde2c706a675316085a41e79ab2c8796a0dd3bdba87d5c996dc0b6f76b438b5d75d2567
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in" "${SOURCE_PATH}/CMakeLists.txt" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CppWinRT-config.cmake.in" DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cppwinrt/cmake)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/cppwinrt/")

file(INSTALL
    "${SOURCE_PATH}/bin/cppwinrt.exe"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cppwinrt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
