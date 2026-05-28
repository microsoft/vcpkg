if(VCPKG_TARGET_IS_LINUX)
    MESSAGE(WARNING "${PORT} requires libbluetooth-dev from the system package manager.\nTry: 'sudo yum install libbluetooth-dev ' (or sudo apt-get install libbluetooth-dev)")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotraconteur/robotraconteur
    REF "v${VERSION}"
    SHA512 f6876d36dbc030e638afdeb58d704f7b50aa7b7a93b46292d83558665cb871a761a1741f19c6fb7208ddc1863ece2b49279477d76f357db45aa8c47082486aec
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_GEN=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES RobotRaconteurGen AUTO_CLEAN)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/robotraconteur)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME RobotRaconteur
    CONFIG_PATH "lib/cmake/RobotRaconteur"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

