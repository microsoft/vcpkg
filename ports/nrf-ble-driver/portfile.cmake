include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(
"${PORT} currently requires the following libraries from the system package manager:
    libudev-dev
These can be installed on Ubuntu systems via sudo apt install libudev-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NordicSemiconductor/pc-ble-driver
    REF v4.1.1
    SHA512 bb1853993b3f37836a8f7402e5c0452e8423c3a1c6e651cf353025022a32e16c72f06e2266e283c72fa7ddb0da7cf8cecb875a7a7762565599f2908c4858ce8e
    HEAD_REF master
    PATCHES
        001-arm64-support.patch
)

# Ensure that git is found within CMakeLists.txt by appending vcpkg's git executable dirpath to $PATH.
# Git should always be available as it is downloaded during the bootstrap phase.
# Append instead of prepend to $PATH to honor the user's git executable as a general rule.
find_program(GIT NAMES git git.cmd)
get_filename_component(GIT_EXE_DIRPATH "${GIT}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${GIT_EXE_DIRPATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_EXAMPLES= -DDISABLE_TESTS= -DNRF_BLE_DRIVER_VERSION=4.1.1 -DCONNECTIVITY_VERSION=4.1.1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)