vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-template-second_1.0.0-beta.30
    SHA512 66dbb14b130662041c897f5533ab158cce2f1ba1f1cdafaa7209302c275315958dfeff009dd1bfccb94d4e869b23fa85bc2456d14c925abcf165d21e5db5b15b
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/template/azure-template-second/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
