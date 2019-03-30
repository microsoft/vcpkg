include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hrydgard/minitrace
    REF a48215c409dd848fa0a76c5eb4dfaba4ca3bca39
    SHA512 591fa52132b6bbe8e7e121526a43d07056deff8fe026227c1a4c26bebf95536e5d68750fa8551d23afebf048fe8b8503017b9a93650e18a992cf2e5678d46135
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/minitrace RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME minitrace)
