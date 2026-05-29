vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF 1.0.2
    SHA512 ed427da8e59f9629f8d70e0a14415f88177c06fbaf7334bee56135dde91d19a1b54f5c9c668e0fd68314ab8dfd61446a174b9f528304decc5d4626a7c98882cb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME console_bridge CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME console_bridge CONFIG_PATH lib/console_bridge/cmake)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/console_bridge")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/console_bridge")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/include/console_bridge/console_bridge_export.h" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC_DEFINE" "if 1" _contents "${_contents}")
else()
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC_DEFINE" "if 0" _contents "${_contents}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/console_bridge/console_bridge_export.h" "${_contents}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
