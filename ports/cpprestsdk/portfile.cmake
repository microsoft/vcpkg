include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF v2.10.5
    SHA512 7942185e0e1cd5080b57737887f44c12e706cfb6428e55762dcbad2fd2c557f25bd26abe25b6abd9769ab6c0cea564541e7e95dcaff53e609124dda065fa41be
    HEAD_REF master
)

set(OPTIONS)
if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    SET(WEBSOCKETPP_PATH "${CURRENT_INSTALLED_DIR}/share/websocketpp")
    list(APPEND OPTIONS
        -DWEBSOCKETPP_CONFIG=${WEBSOCKETPP_PATH}
        -DWEBSOCKETPP_CONFIG_VERSION=${WEBSOCKETPP_PATH})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Release
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXCLUDE_WEBSOCKETS=OFF
        -DCPPREST_EXPORT_DIR=share/cpprestsdk
        -DWERROR=OFF
    OPTIONS_DEBUG
        -DCPPREST_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(INSTALL
    ${SOURCE_PATH}/license.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpprestsdk RENAME copyright)

vcpkg_copy_pdbs()

