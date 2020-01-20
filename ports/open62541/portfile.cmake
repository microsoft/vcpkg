include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION v1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF ${VERSION}
    SHA512 a1cc614147ee7fc0b4246abb0dd1a3405e330760c1d9d76980700853f136f7562690906cb428bae81232355d03f27c1cdc71da85e23e0cf16167f42d4faff93b
    HEAD_REF master
)

file(READ ${SOURCE_PATH}/CMakeLists.txt OPEN62541_CMAKELISTS)
string(REPLACE
    "RUNTIME DESTINATION \${CMAKE_INSTALL_PREFIX}"
    "RUNTIME DESTINATION \${BIN_INSTALL_DIR}"
    OPEN62541_CMAKELISTS "${OPEN62541_CMAKELISTS}"
)
file(WRITE ${SOURCE_PATH}/CMakeLists.txt "${OPEN62541_CMAKELISTS}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBIN_INSTALL_DIR:STRING=bin
        -DOPEN62541_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/open62541/tools)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})