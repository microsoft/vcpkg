file(READ "${CMAKE_CURRENT_LIST_DIR}/../libcroco/usage" usage)
message(WARNING "find_package(unofficial-libcroco) is deprecated.\n${usage}")

include(CMakeFindDependencyMacro)
find_dependency(PkgConfig)
pkg_check_modules(VCPKG_LIBCROCO libcroco-0.6 IMPORTED_TARGET)
if(NOT VCPKG_LIBCROCO_FOUND)
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND 0)
elseif(NOT TARGET unofficial::libcroco::croco-0.6)
    add_library(unofficial::libcroco::croco-0.6 INTERFACE IMPORTED)
    set_target_properties(unofficial::libcroco::croco-0.6 PROPERTIES
        INTERFACE_LINK_LIBRARIES PkgConfig::VCPKG_LIBCROCO
    )
endif()
