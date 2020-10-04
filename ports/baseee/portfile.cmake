# Download File From Github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chhdao/baseee
    REF 007384a153d2989e5e955af560d3f36b792e9e6a
    SHA512 65eece7c12ab236420940fcea876bb8a064a5502a9a764519a740c180b9d81976048be48f918d141d2a36151bfef8abfdb2fc6684f8da5effe96835dfe04ddba
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