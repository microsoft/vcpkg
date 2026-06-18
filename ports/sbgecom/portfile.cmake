vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SBG-Systems/sbgECom
    REF "${VERSION}-stable"
    SHA512 1c3a824f9fe65e8d782afae60c05ebf8278803f0edba1f2ac741381846512c9e29ac4ae4b1f5f014348a569ed8d2524d95b6eea6c9a4c3305e9a81c113ff940d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "sbgECom"
    CONFIG_PATH lib/cmake/sbgECom
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
