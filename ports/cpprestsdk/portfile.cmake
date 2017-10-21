include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF v2.10.0
    SHA512 78e7a38c21db5b563d08cb082bfa96360ac44c66f2189a614d3d2bb71655fd82d931f138590d2dba2d6a4c0884ae37a5be34ea3b753c3517bd68ce490daf60b4
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
    OPTIONS_DEBUG
        -DCPPREST_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(INSTALL
    ${SOURCE_PATH}/license.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpprestsdk RENAME copyright)

vcpkg_copy_pdbs()

