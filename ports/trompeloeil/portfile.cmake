vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v41
    SHA512 f68a3f1c5f2cd1b49fb8c90612383d68ca1a0bcd1ca6b0a0fbe6e3cef23af011b5503d788023519f182a1221d55774796115f9248caf33175f919fd18e5e43f9
    HEAD_REF master
    PATCHES disable_master_project.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

configure_file("${SOURCE_PATH}/LICENSE_1_0.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
