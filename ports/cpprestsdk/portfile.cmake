include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF v2.10.1
    SHA512 f6a93e5e87e27db724ccc028326b1dce243617cb0ae0d101b2cea700c4f264c073cb0e8a9d88a14be165e16ef2f1f43a17e49278087bc8cf372e623a1b6a9c47
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

