vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-identity_1.0.0
    SHA512 de2de96c3ddce8b289328282c5ad89a4e96ee8b4c7398964a874ddddb7afd232005213b0f25e343ac6b08ecec9636006d395a61fd0dcf67db09ab7e7ec2d7201
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/identity/azure-identity/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
