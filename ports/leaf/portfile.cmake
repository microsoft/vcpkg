include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zajo/leaf
    REF 5fd08ee095c92b2bf4623b7237393e81f995ca7a
    SHA512 92b86dbba55d31808f442d27dd873dce1162b28213533e124df448ae4f7b4442733501b6539ab15f67a85e184e458a66df4e4e020a3a213b44578ebbde281a42
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/leaf RENAME copyright)
