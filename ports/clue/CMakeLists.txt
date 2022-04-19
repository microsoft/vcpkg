cmake_minimum_required(VERSION 3.5)

project(clue VERSION 1.0.0 LANGUAGES CXX)

option(CLUE_BUILD_TEST     "Build tests for clue" OFF)
option(CLUE_BUILD_EXAMPLE  "Build examples" OFF)

include(GNUInstallDirs)
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include/clue.hpp")

if(CLUE_BUILD_TEST)
    file(GLOB TEST_SOURCES "tests/*.cpp")
    add_executable(test_clue ${TEST_SOURCES})
    target_include_directories(test_clue PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" "${CMAKE_CURRENT_SOURCE_DIR}/tests")
    install(TARGETS test_clue
            RUNTIME DESTINATION tools)
endif()

if(CLUE_BUILD_EXAMPLE)
    file(GLOB EXAMPLES "examples/*.cpp")
    install(FILES ${EXAMPLES} DESTINATION examples)
endif()

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/include/clue.hpp" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
# end of file