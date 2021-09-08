vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lv2
    REF cd152104c84bcee9fec22ef780cec2af7ba85d0c #v1.18.2
    SHA512 77220524481e97222b12782a89efdcfcb73ee6ac9b9aac88741475c60a2c21049153297860a24b77c0ebd4de32d38a38232ba4fc64d12b8558a56ef50b316801
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(
    INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
