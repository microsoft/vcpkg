# Download File From Github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chhdao/baseee
    REF 857f322dbce21b427392cbd477583fb6b32e968d
    SHA512 6a74181d48d8b04d6e6e14eee93a3ad5e6781f6dab1e8b1b260235e99fc9131420d7807f5f742977f1bcee80aaf6b1f598ece269472b29ab0c36dd50c6111a61
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