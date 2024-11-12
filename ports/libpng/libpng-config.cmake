file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(WARNING "find_package(libpng) is deprecated.\n${usage}")

include(CMakeFindDependencyMacro)
find_dependency(PNG CONFIG)

if(NOT TARGET png_shared)
    add_library(png_shared ALIAS PNG::PNG)
endif()
if(NOT TARGET png_static)
    add_library(png_static ALIAS PNG::PNG)
endif()
