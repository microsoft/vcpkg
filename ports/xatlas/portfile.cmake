vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpcy/xatlas
    REF f700c7790aaa030e794b52ba7791a05c085faf0c
    SHA512 1f7afcc9056ab636abef017033aaf63d219cdec95e871beade2c694f8e8b4a58563cf506c5afb6d0d5536233f791e11adbcf3f6f26548105b31d381289892dea
    HEAD_REF master
)

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.10)
project(xatlas LANGUAGES CXX)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON) 

add_library(xatlas source/xatlas/xatlas.cpp)
add_library(xatlas::xatlas ALIAS xatlas)

target_include_directories(xatlas PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/xatlas>
    $<INSTALL_INTERFACE:include>
)

install(TARGETS xatlas EXPORT xatlas-config 
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT xatlas-config NAMESPACE xatlas:: DESTINATION share/xatlas)
install(FILES source/xatlas/xatlas.h DESTINATION include)
]=])


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")