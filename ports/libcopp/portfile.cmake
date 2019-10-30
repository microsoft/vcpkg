include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owt5008137/libcopp
    REF 1.2.1
    SHA512 bd3525b7cafb261b395ab767d30654ee7c2920f2b8312ed7887b004e764b8dd8dece5f34a5f7724d16c4a56a281ea9eb3107eff54c947160fbf9f12b76b34485
    HEAD_REF v2
)

# Use libcopp's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    # PREFER_NINJA # Disabled because Ninja does not invoke masm correctly for this project
)
vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/BOOST_LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
