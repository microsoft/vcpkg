PROJECT (AstronomicalAlgorithms)

cmake_minimum_required(VERSION 3.11)
cmake_policy(VERSION 3.11)

project(libaaplus LANGUAGES CXX)

option(BUILD_TOOLS "Build libaaplus tools" OFF)

file(GLOB LIBS_SRC RELATIVE ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

list(REMOVE_ITEM ${LIBS_SRC} AATest.cpp)

file(GLOB PUBLIC_HEADERS RELATIVE ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/*.h)

set(TEST_SRCS
  AATest.cpp
)

add_library(libaaplus
    ${LIBS_SRC}
)

if (MSVC AND BUILD_SHARED_LIBS)
target_compile_definitions(libaaplus
    PRIVATE
        -DAAPLUS_EXT_CLASS\=__declspec\(dllexport\)
)
endif (MSVC AND BUILD_SHARED_LIBS)

install(
    TARGETS libaaplus
    EXPORT libaaplus
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Headers makes relative includes so directory structure must be kept
foreach(HEADER ${PUBLIC_HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(
        FILES ${HEADER}
        DESTINATION include/aaplus/${HEADER_DIR}
    )
endforeach()


if (BUILD_TOOLS)
    add_executable(aatest AATest.cpp)
    target_link_libraries(aatest PRIVATE libaaplus)
    if (BUILD_SHARED_LIBS AND MSVC)
        target_compile_definitions(aatest
            PUBLIC
            -DAAPLUS_EXT_CLASS\=__declspec\(dllimport\)
        )
    endif (BUILD_SHARED_LIBS AND MSVC)
    
    install(TARGETS aatest RUNTIME DESTINATION tools/aaplus)
endif()

install(
    EXPORT libaaplus
    DESTINATION share/libaaplus
    FILE libaaplusConfig.cmake
    NAMESPACE libaaplus::
)
