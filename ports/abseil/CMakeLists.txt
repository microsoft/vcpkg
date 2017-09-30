cmake_minimum_required(VERSION 3.8)
project(abseil CXX)

add_definitions(-DNOMINMAX)

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

option(INSTALL_HEADERS "Install header files" ON)

function(add_sublibrary LIB)
    file(GLOB_RECURSE SOURCES "absl/${LIB}/*.cc")
    list(FILTER SOURCES EXCLUDE REGEX "_test")
    file(GLOB HEADERS "absl/${LIB}/*.h")
    file(GLOB INTERNAL_HEADERS "absl/${LIB}/internal/*.h")

    if(SOURCES)
        add_library(${LIB} ${SOURCES})
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
            install(FILES ${HEADERS} DESTINATION "include/absl/${LIB}")
        endif()
        if(INTERNAL_HEADERS)
            install(FILES ${INTERNAL_HEADERS} DESTINATION "include/absl/${LIB}/internal")
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

add_sublibrary(base)
add_sublibrary(meta)
add_sublibrary(algorithm)
add_sublibrary(container)
add_sublibrary(memory)
add_sublibrary(strings)
add_sublibrary(debugging)
add_sublibrary(numeric)
add_sublibrary(types)
add_sublibrary(utility)

target_link_public_libraries(algorithm base meta)
target_link_public_libraries(container algorithm base memory)
target_link_public_libraries(memory meta)
target_link_public_libraries(meta base)
target_link_public_libraries(numeric base)
target_link_public_libraries(strings base memory meta numeric)
target_link_public_libraries(types base utility meta algorithm strings)
target_link_public_libraries(utility base meta)

install(
    EXPORT unofficial-abseil-targets
    FILE unofficial-abseil-config.cmake
    NAMESPACE unofficial::abseil::
    DESTINATION share/unofficial-abseil
)