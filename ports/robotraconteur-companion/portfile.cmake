vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotraconteur/robotraconteur_companion
    REF "v${VERSION}"
    SHA512 9df5fc4afe635b86cf150e59f06a809b856f17921507e75872f6afe723d2b9654cbb0ecc43533d3c7d673c11fb96545d627f4bbacdbd351a1a61d0ee65d71381
    HEAD_REF master
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

