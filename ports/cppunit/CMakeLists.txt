project(cppunit)
cmake_minimum_required(VERSION 2.8.12)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" 
    CACHE PATH "Installation directory for executables"
)
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" 
    CACHE PATH "Installation directory for libraries"
)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" 
    CACHE PATH "Installation directory for headers"
)

file(GLOB CPPUNIT_SRC RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/cppunit/*.cpp")
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set(DLLPLUGINTESTER_SRC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/DllPlugInTester/CommandLineParser.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/DllPlugInTester/DllPlugInTester.cpp
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/DllPlugInTester)

if(WIN32)
    set(CMAKE_DEBUG_POSTFIX d)
endif()

if(BUILD_SHARED_LIBS)
    add_library(cppunit SHARED ${CPPUNIT_SRC})
    add_definitions(-DCPPUNIT_BUILD_DLL)
else()
    add_library(cppunit STATIC ${CPPUNIT_SRC})
endif()

add_executable(DllPlugInTester ${DLLPLUGINTESTER_SRC})
target_link_libraries(DllPlugInTester cppunit)

install(TARGETS cppunit
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
)

install(TARGETS DllPlugInTester 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/include/cppunit" 
        DESTINATION "${INSTALL_INC_DIR}"
)
