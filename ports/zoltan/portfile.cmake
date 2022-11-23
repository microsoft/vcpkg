# https://sandialabs.github.io/Zoltan/ug_html/ug_usage.html#Building%20the%20Library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  trilinos/Trilinos # probably easier to have a Trilinos port later and have all the subprojects as features of that port. 
    REF 3cf925bab1d6ac071e5aff9671cce5a5889accf2 # 13.4.1
    SHA512 383a185f2111780c86ca500f80ea57383d1bd518e35414cdde643027cb7ccfd8656f08da7cc61be5a0820df0b67837e795314909ac420b638ee10d2c4bb819c8
    HEAD_REF master
)


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTrilinos_ENABLE_ALL_PACKAGES:BOOL=OFF
        -DTrilinos_ENABLE_Zoltan:BOOL=ON
        -DTrilinos_ENABLE_Fortran:BOOL=OFF 
        #-DTPL_ENABLE_MPI:BOOL=ON 
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tribits PACKAGE_NAME tribits DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trilinos PACKAGE_NAME Trilinos DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Zoltan PACKAGE_NAME Zoltan DO_NOT_DELETE_PARENT_CONFIG_PATH)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/packages/${PORT}/COPYRIGHT_AND_LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
