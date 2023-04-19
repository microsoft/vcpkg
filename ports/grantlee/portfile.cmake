vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steveire/grantlee
    REF v5.3.1
    SHA512 dc7192fe0553954fffc3e2c584e4fdd80fc1f22d25846cacc5f2dcd1db2673ca62464c8492a4ed3bfc9dfc3e62ef13322809dd29bd56fa4a3a153a8d373ddde5
    HEAD_REF master
)

vcpkg_cmake_configure (
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGRANTLEE_BUILD_WITH_QT6=ON
        -DBUILD_TESTS=OFF
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" [[set( PLUGIN_INSTALL_DIR ${LIB_INSTALL_DIR}/grantlee/${Grantlee5_MAJOR_MINOR_VERSION_STRING} )]] [[set( PLUGIN_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/bin)]])

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Grantlee5)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
