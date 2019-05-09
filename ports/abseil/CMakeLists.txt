cmake_minimum_required(VERSION 3.8)
project(abseil CXX)

add_definitions(-DNOMINMAX -DWIN32_LEAN_AND_MEAN)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_DEBUG_POSTFIX d)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    option(INSTALL_HEADERS "Install header files" ON)
else()
    option(INSTALL_HEADERS "Install header files" OFF)
endif()

function(add_sublibrary LIB)
    file(GLOB_RECURSE SOURCES "absl/${LIB}/*.cc")
    list(FILTER SOURCES EXCLUDE REGEX "_test(ing)?(_.+)?.cc$|_nonprod.cc$|test_util.cc$|_benchmark.cc$")
    file(GLOB_RECURSE HEADERS "absl/${LIB}/*.h" "absl/${LIB}/*.inc")

    if(SOURCES)
        if("STATIC" IN_LIST ARGN)
            add_library(${LIB} STATIC ${SOURCES})
        else()
            add_library(${LIB} ${SOURCES})
        endif()
        set_target_properties(${LIB} PROPERTIES OUTPUT_NAME "absl_${LIB}")
        target_include_directories(${LIB} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
    else()
        add_library(${LIB} INTERFACE)
        target_include_directories(${LIB} INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
    endif()

    install(TARGETS ${LIB} EXPORT unofficial-abseil-targets
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
    )

    if(INSTALL_HEADERS)
        if(HEADERS)
            foreach(file IN LISTS HEADERS)
                get_filename_component(dir ${file} DIRECTORY)
                file(RELATIVE_PATH rel_dir ${CMAKE_SOURCE_DIR}/absl/${LIB} ${dir})
                install(FILES ${file} DESTINATION "include/absl/${LIB}/${rel_dir}")
            endforeach()
        endif()
    endif()
endfunction()

function(target_link_public_libraries A)
    get_target_property(A_TYPE ${A} TYPE)
    if(A_TYPE STREQUAL INTERFACE_LIBRARY)
        target_link_libraries(${A} INTERFACE ${ARGN})
    else()
        target_link_libraries(${A} PUBLIC ${ARGN})
    endif()
endfunction()

add_sublibrary(algorithm)
add_sublibrary(base)
add_sublibrary(container STATIC)
add_sublibrary(debugging)
add_sublibrary(hash)
add_sublibrary(memory)
add_sublibrary(meta)
add_sublibrary(numeric)
add_sublibrary(strings)
add_sublibrary(synchronization STATIC)
# Time must be static because there are global variables intended for export
add_sublibrary(time STATIC)
add_sublibrary(types)
add_sublibrary(utility)

target_link_public_libraries(algorithm base meta)
target_link_public_libraries(container algorithm base memory time)
target_link_public_libraries(debugging base)
target_link_public_libraries(hash base)
target_link_public_libraries(memory meta)
target_link_public_libraries(meta base)
target_link_public_libraries(numeric base)
target_link_public_libraries(strings base memory meta numeric)
target_link_public_libraries(types base utility meta algorithm strings)
target_link_public_libraries(utility base meta)
target_link_public_libraries(time base numeric)
target_link_public_libraries(synchronization base time)

install(
    EXPORT unofficial-abseil-targets
    FILE unofficial-abseil-config.cmake
    NAMESPACE unofficial::abseil::
    DESTINATION share/unofficial-abseil
)
