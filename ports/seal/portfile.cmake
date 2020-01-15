set(SEAL_VERSION_MAJOR 3)
set(SEAL_VERSION_MINOR 4)
set(SEAL_VERSION_MICRO 5)

string(TOUPPER ${PORT} PORT_UPPER)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF 9fc376c19488be2bfd213780ee06789754f4b2c2
    SHA512 198f75371c7b0b88066495a40c687c32725a033fd1b3e3dadde3165da8546d44e9eaa9355366dd5527058ae2171175f757f69189cf7f5255f51eba14c6f38b78
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/native/src
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT_UPPER}-${SEAL_VERSION_MAJOR}.${SEAL_VERSION_MINOR})

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
