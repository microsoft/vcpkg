cmake_minimum_required(VERSION 3.16)
project(lua-test C CXX)

find_package(Lua REQUIRED)

add_executable(main main.c)
target_include_directories(main PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(main PRIVATE ${LUA_LIBRARIES})
install(TARGETS main RUNTIME DESTINATION bin/vcpkg-ci-lua)

if("cpp" IN_LIST FEATURES)
    find_package(unofficial-lua REQUIRED)

    add_executable(main-cpp main.cpp)
    target_link_libraries(main-cpp PRIVATE unofficial::lua::lua-cpp)
endif()
