cmake_minimum_required(VERSION 3.16)
project(icu-test C CXX)

include("${CMAKE_CURRENT_LIST_DIR}/test-functions.cmake")

find_package(ICU MODULE COMPONENTS i18n REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE ICU::i18n)


find_package(PkgConfig REQUIRED)
pkg_check_modules(icu_pc icu-i18n REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::icu_pc)

# Validate other components

set(required_components data dt in io tu uc)
if(VCPKG_CROSSCOMPILING)
    list(REMOVE_ITEM required_components tu) # comes with (host) tools
endif()
vcpkg_check_cmake_package_find(ICU MODULE REQUIRED COMPONENTS ${required_components})
vcpkg_check_cmake_package_variables()
vcpkg_check_cmake_package_targets()
