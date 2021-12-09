cmake_minimum_required(VERSION 3.12.0)

set(PROJECT_VERSION "0.1.0")
project(qjsonwebtoken VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5Core REQUIRED)

set(HEADERS "src/QJsonWebToken" "src/qjsonwebtoken.h")
set(SOURCES "src/qjsonwebtoken.cpp")

add_library(qjsonwebtoken INTERFACE ${SOURCES} )
target_link_libraries(qjsonwebtoken INTERFACE Qt5::Core)

target_include_directories(qjsonwebtoken 
    INTERFACE $<INSTALL_INTERFACE:include>
)

install(TARGETS qjsonwebtoken
    EXPORT unofficial-qjsonwebtokenTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-qjsonwebtoken-config.cmake"
[[include(CMakeFindDependencyMacro)
find_dependency(Qt5Core)
include("unofficial-qjsonwebtokenTargets.cmake")
]])
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-qjsonwebtoken-config.cmake DESTINATION share/unofficial-qjsonwebtoken)

install(EXPORT unofficial-qjsonwebtokenTargets
FILE
  unofficial-qjsonwebtokenTargets.cmake
NAMESPACE
  unofficial-qjsonwebtoken::
DESTINATION
  share/unofficial-qjsonwebtoken
)
install(FILES ${HEADERS} ${SOURCES} DESTINATION include)
