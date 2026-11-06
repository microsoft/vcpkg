vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SBG-Systems/sbgECom
    REF "${VERSION}-stable"
    SHA512 12888a8d983d715b16fc8389506c223c8071d4939f121b7162cd60bf94142bf9dbce1f34a419ba3843a91cd893ec63505be12b967de8255387b7c2062d14a096
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
