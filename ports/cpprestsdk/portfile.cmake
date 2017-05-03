include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF v2.9.0
    SHA512 c75de6ad33b3e8d2c6ba7c0955ed851d557f78652fb38a565de0cfbc99e7db89cb6fa405857512e5149df80356c51ae9335abd914c3c593fa6658ac50adf4e29
    HEAD_REF master
)
if(NOT VCPKG_USE_HEAD_VERSION)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002_no_websocketpp_in_uwp.patch
    )
endif()

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
        -DCASA_INSTALL_HEADERS=OFF
        -DCPPREST_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if(VCPKG_USE_HEAD_VERSION)
    vcpkg_fixup_cmake_targets()
endif()

file(INSTALL
    ${SOURCE_PATH}/license.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpprestsdk RENAME copyright)

vcpkg_copy_pdbs()

