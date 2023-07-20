file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(AUTHOR_WARNING "find_package(skia) is deprecated.\n${usage}")
include(CMakeFindDependencyMacro)
find_dependency(unofficial-skia)
if(NOT TARGET skia)
    add_library(skia INTERFACE IMPORTED)
    set_target_properties(skia PROPERTIES
        INTERFACE_LINK_LIBRARIES unofficial::skia::skia
    )
    add_library(skia::skia ALIAS skia)
endif()
