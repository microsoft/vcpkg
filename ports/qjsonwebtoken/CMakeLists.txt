cmake_minimum_required(VERSION 3.12.0)

set(PROJECT_VERSION "0.1.0")
project(qjsonwebtoken VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5Core REQUIRED)

add_library( qjsonwebtoken STATIC src/QJsonWebToken src/qjsonwebtoken.h src/qjsonwebtoken.cpp )
target_link_libraries(qjsonwebtoken Qt5::Core)

install(FILES src/QJsonWebToken src/qjsonwebtoken.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include)
install(TARGETS qjsonwebtoken DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
