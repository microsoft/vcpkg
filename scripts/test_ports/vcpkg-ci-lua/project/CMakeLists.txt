cmake_minimum_required(VERSION 3.16)
project(lua-test C)

find_package(Lua REQUIRED)

add_executable(main main.c)
target_include_directories(main PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(main PRIVATE ${LUA_LIBRARIES})
install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-lua)
