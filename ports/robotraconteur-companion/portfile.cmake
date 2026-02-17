vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotraconteur/robotraconteur_companion
    REF "v${VERSION}"
    SHA512 8bee3f71f6f1cedc6af9b30d32ed16515c2c117a4d43c3b6304c799fe90447056c5e447f573c96018c57112d9c174de422c16eba3a27b5c1343e88377d7e4117
    HEAD_REF master
    PATCHES
        0001-support-eigen3-5.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH ROBDEF_SOURCE_PATH
    REPO robotraconteur/robotraconteur_standard_robdef
    REF group1-v1
    SHA512 84724717e57c6e7ceefa957a8d94ee68db189e9a114564662d37b16a307735feea2a01c5622140118f537e6c084437d4bf11d0eb1e015b475fb3b636ed5009aa
    HEAD_REF master
)

file(COPY ${ROBDEF_SOURCE_PATH}/group1 DESTINATION ${SOURCE_PATH}/robdef/)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME RobotRaconteurCompanion
    CONFIG_PATH "lib/cmake/RobotRaconteurCompanion"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

