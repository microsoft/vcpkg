cmake_minimum_required (VERSION 3.8.0)
project (libcunit C CXX)
set(CMAKE_CXX_STANDARD 11)


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
set(HEADERS_DIR  "${PROJECT_SOURCE_DIR}/CUnit/Headers")
set(SOURCES_DIR "${PROJECT_SOURCE_DIR}/CUnit/Sources")
set(EXAMPLES_DIR "${PROJECT_SOURCE_DIR}/Examples")

configure_file(
  "${HEADERS_DIR}/CUnit.h.in"
  "${PROJECT_BINARY_DIR}/CUnit.h"
)
include_directories("${PROJECT_BINARY_DIR}")
include_directories(${HEADERS_DIR})
include_directories(${EXAMPLES_DIR})

file(GLOB TARGET_SRC
  "${SOURCES_DIR}/Automated/Automated.c"
  "${SOURCES_DIR}/Basic/Basic.c"
  "${SOURCES_DIR}/Console/Console.c"
  "${SOURCES_DIR}/Framework/CUError.c"
  "${SOURCES_DIR}/Framework/MyMem.c"
  "${SOURCES_DIR}/Framework/TestDB.c"
  "${SOURCES_DIR}/Framework/TestRun.c"
  "${SOURCES_DIR}/Framework/Util.c"
)

add_library(libcunit SHARED ${TARGET_SRC})

if (MSVC)
   add_definitions( "/W3 /D_CRT_SECURE_NO_WARNINGS /wd4005 /wd4996 /nologo /DCU_BUILD_DLL /DCU_DLL" )
endif()

add_executable(AutomatedTest ${EXAMPLES_DIR}/AutomatedTest/AutomatedTest.c "${EXAMPLES_DIR}/ExampleTests.c")
add_executable(BasicTest ${EXAMPLES_DIR}/BasicTest/BasicTest.c "${EXAMPLES_DIR}/ExampleTests.c")
add_executable(ConsoleTest ${EXAMPLES_DIR}/ConsoleTest/ConsoleTest.c "${EXAMPLES_DIR}/ExampleTests.c")

target_link_libraries(AutomatedTest libcunit)
target_link_libraries(BasicTest libcunit)
target_link_libraries(ConsoleTest libcunit)
