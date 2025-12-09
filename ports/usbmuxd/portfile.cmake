vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/usbmuxd
    REF 61b99ab5c25609c11369733a0df97c03a0581a56 # commits on 2023-07-21
    SHA512 1b67a41f43e78bbf0966cbe68c9e35351d5a163d7d82aa6e5caed6c4f8ffc3c28faf74dc96890a35481b4856f6b6d95ebec9e8d2a665a099d8909b91bf408381
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES usbmuxd AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.GPLv2" "${SOURCE_PATH}/COPYING.GPLv3")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
