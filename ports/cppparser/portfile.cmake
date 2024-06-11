vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agladilin/cppparser
    REF "${VERSION}"
    SHA512 6fea5a6f7a172b8e828382871ad1dcb102ab700d617a1d2b753b6e0bfef7639e0b40778fdceb196e6b0b1b5e75c9173a1cb1eb667906ec7471118b74c5dbfce1
    HEAD_REF master
)


vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "cppparser" CONFIG_PATH lib)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

#install(
#    FILES ${config_version_file} ${install_config}
#    DESTINATION "${CPPPARSER_INSTALL_CONFIG_DIR}"
#)
