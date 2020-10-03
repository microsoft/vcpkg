# Download File From Github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chhdao/baseee
    REF e75c89b3d6dd964b6d78f478178195edc596279e
    SHA512 2f5a27d8e396b60ee45d26f40c3587504905b0ce4ff4ce845f72fe5702a96bb55d8bfa4b16c9825769cbc74f0126987732e62c00c05c18728366b8e41835d657
    HEAD_REF master
)

#Build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/baseee
    PREFER_NINJA 
)
               
vcpkg_install_cmake()

# Add License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/baseee/copyright)

# do something
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")