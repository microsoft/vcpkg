cmake_minimum_required(VERSION 3.25.1)

project(tdlib-test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Td CONFIG REQUIRED)

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND TARGET Td::tdjson_static)
    get_property(imported_targets DIRECTORY PROPERTY IMPORTED_TARGETS)
    foreach(target IN LISTS imported_targets)
        if (NOT target MATCHES "^Td::")
            continue()
        endif()
        get_target_property(type "${target}" TYPE)
        if (NOT type STREQUAL "STATIC_LIBRARY")
            continue()
        endif()
        get_target_property(configurations "${target}" IMPORTED_CONFIGURATIONS)
        foreach(configuration IN LISTS configurations)
            get_target_property(library "${target}" "IMPORTED_LOCATION_${configuration}")
            if (NOT library)
                message(FATAL_ERROR "No ${configuration} library found for ${target}")
            endif()
            cmake_path(REPLACE_EXTENSION library ".pdb" OUTPUT_VARIABLE pdb)
            if (NOT EXISTS "${pdb}")
                message(FATAL_ERROR "Compiler PDB for ${library} not found: ${pdb}")
            endif()
        endforeach()
    endforeach()
endif()

add_executable(main main.cpp)

if (TARGET Td::tdjson_static)
    target_link_libraries(main PRIVATE Td::tdjson_static)
else()
    target_link_libraries(main PRIVATE Td::tdjson)
endif()

find_package(PkgConfig REQUIRED)

pkg_check_modules(tdjson_static IMPORTED_TARGET tdjson_static)
pkg_check_modules(tdjson IMPORTED_TARGET tdjson)

add_executable(main2 main.cpp)

if (TARGET PkgConfig::tdjson_static)
    target_link_libraries(main2 PRIVATE PkgConfig::tdjson_static)
else()
    target_link_libraries(main2 PRIVATE PkgConfig::tdjson)
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND TARGET Td::tdjson_static)
    target_link_options(main PRIVATE /DEBUG /WX /LTCG /INCREMENTAL:NO)
    target_link_options(main2 PRIVATE /DEBUG /LTCG /INCREMENTAL:NO)
endif()
