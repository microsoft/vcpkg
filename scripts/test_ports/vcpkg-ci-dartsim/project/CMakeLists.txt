cmake_minimum_required(VERSION 3.30)
project(dartsim-test CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

block(SCOPE_FOR VARIABLES)
    find_package(DART CONFIG REQUIRED)
    add_library(target::dart ALIAS dart)

    add_executable(main-dart main.cpp)
    target_link_libraries(main-dart PRIVATE target::dart)

    # check link libs from all components
    file(GLOB components RELATIVE "${DART_DIR}" "${DART_DIR}/dart_*Component.cmake")
    list(TRANSFORM components REPLACE "^dart_(.*)Component.cmake\$" "\\1")
    find_package(DART CONFIG COMPONENTS ${components})

    add_executable(main-all main.cpp)
    target_link_libraries(main-all PRIVATE ${DART_LIBRARIES})
endblock()

block(SCOPE_FOR VARIABLES)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(dartsim_pc dart REQUIRED IMPORTED_TARGET)

    add_executable(main-pkconfig main.cpp)
    target_link_libraries(main-pkconfig PRIVATE PkgConfig::dartsim_pc)
endblock()
