# Download File From Github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chhdao/baseee
    REF 74a911c03709a8e1c96cad930dd721c8aa8ccfa1
    SHA512 89c164ed1cb5853a03b4b2e14cd7969b97fef0cbd8b343744b7a21105e1002e2f1525eb81d0fcdb25aac42b4b2abdec03bb4dcf084176b2d4d86c614a48ed3c4
    HEAD_REF master
)

#Build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/baseee
    PREFER_NINJA 
)
               
vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Add License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/baseee/copyright)

# do something
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")