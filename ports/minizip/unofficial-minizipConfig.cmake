file(READ "${CMAKE_CURRENT_LIST_DIR}/../minizip/usage" usage)
message(WARNING "'find_package(unofficial-minizip)' is deprecated.\n${usage}")

if(NOT TARGET unofficial::minizip::minizip)
    include(CMakeFindDependencyMacro)
    find_dependency(minizip CONFIG)
    add_library(unofficial::minizip::minizip INTERFACE IMPORTED)
    set_target_properties(unofficial::minizip::minizip PROPERTIES INTERFACE_LINK_LIBRARIES $<IF:$<TARGET_EXISTS:MINIZIP::minizip>,MINIZIP::minizip,MINIZIP::minizipstatic>)
endif()
