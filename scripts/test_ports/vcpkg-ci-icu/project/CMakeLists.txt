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

# Known issue: C++ linkage

set_target_properties(main main-pkconfig PROPERTIES LINKER_LANGUAGE CXX)

# Known issue: transitive usage requirements

find_package(ICU MODULE REQUIRED COMPONENTS data uc)
set_target_properties(ICU::i18n PROPERTIES INTERFACE_LINK_LIBRARIES ICU::uc)
set_target_properties(ICU::uc PROPERTIES INTERFACE_LINK_LIBRARIES ICU::data)

# Validate all expected components

vcpkg_check_cmake_package_find(ICU MODULE REQUIRED COMPONENTS data dt i18n in io tu uc)
vcpkg_check_cmake_package_variables()
vcpkg_check_cmake_package_targets()
