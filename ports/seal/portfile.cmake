set(SEAL_VERSION_MAJOR 3)
set(SEAL_VERSION_MINOR 4)
set(SEAL_VERSION_MICRO 5)

vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platform" ON_TARGET "Windows")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SEAL_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SEAL_BUILD_STATIC)

if (SEAL_BUILD_STATIC)
    set(SEAL_LIB_BUILD_TYPE "Static_PIC")
endif ()

if (SEAL_BUILD_DYNAMIC)
    set(SEAL_LIB_BUILD_TYPE "Shared")
endif ()

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
    OPTIONS
        -DALLOW_COMMAND_LINE_BUILD=ON
        -DSEAL_LIB_BUILD_TYPE=${SEAL_LIB_BUILD_TYPE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT_UPPER}-${SEAL_VERSION_MAJOR}.${SEAL_VERSION_MINOR})

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
