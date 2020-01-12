vcpkg_fail_port_install(MESSAGE "aws-greengrass-core-sdk-c currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/aws-greengrass-core-sdk-c
    REF v1.2.0
    SHA512 10d886d580b17fc1628b7ea534b106fed3730467bcf1008e233e1f5530996c53849a9b8daf5cc3427d6fb182ab5a6e5780480f5deefa8f6b33fcb1fc7ee36319
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-greengrass-core-sdk-c/cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
	${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}
	${CURRENT_PACKAGES_DIR}/lib/${PORT}
)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)



