cmake_minimum_required(VERSION 3.16)
project(sol2-test C CXX)

set(CMAKE_CXX_STANDARD 17)

# Select a Lua implementation
find_package(Lua REQUIRED)


find_package(sol2 CONFIG REQUIRED)

add_executable(main-cmake main.cpp)
target_link_libraries(main-cmake PRIVATE sol2::sol2)

target_link_libraries(sol2::sol2 INTERFACE ${LUA_LIBRARIES})


find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_SOL2 sol2 REQUIRED)

add_executable(main-pkgconfig main.cpp)
target_include_directories(main-pkgconfig PRIVATE ${PC_SOL2_INCLUDE_DIRS})
target_link_libraries(main-pkgconfig PRIVATE ${PC_SOL2_LUA_LIBRARIES})

target_link_libraries(main-pkgconfig PRIVATE ${LUA_LIBRARIES})
