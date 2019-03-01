include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/stk
    REF v4.6.0
    SHA512 8e40dbd9e2b315df769262889fdf15b4a67843984d27a1f939d8bc6e820abb662eeae3b934fa81097222c67f7922681fe170006bebe5597cbd51b0a8624a6733
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-libstk TARGET_PATH share/unofficial-libstk)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libstk RENAME copyright)

file(GLOB RAWFILES ${SOURCE_PATH}/rawwaves/*.raw)
file(COPY ${RAWFILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/libstk/rawwaves)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME libstk)
