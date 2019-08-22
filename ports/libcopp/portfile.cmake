include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owt5008137/libcopp
    REF 1.2.0
    SHA512 7e98380cb6a8d7ae9b458fe609e2ebce15da4b1ee6cc5570112685f484ef42466f4974aa14fce90715ef175125acef47097b36bb7707abd6950581b8ec03c541
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
