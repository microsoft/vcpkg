# Not using/wrapping FindLua.cmake because
# it poorly handles new Lua versions and multi-config.
_find_package(${ARGS} NAMES unofficial-lua)
if(Lua_FOUND)
    get_filename_component(LUA_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}" PATH)
    get_filename_component(LUA_INCLUDE_DIR "${LUA_INCLUDE_DIR}" PATH)
    set(LUA_INCLUDE_DIR ${LUA_INCLUDE_DIR}/include)
    set(LUA_LIBRARIES unofficial::lua::lua)
    # deprecated vars
    set(LUA_FOUND 1)
    set(LUA_VERSION_STRING "${Lua_VERSION}")
    set(LUA_VERSION_MAJOR "${Lua_VERSION_MAJOR}")
    set(LUA_VERSION_MINOR "${Lua_VERSION_MINOR}")
    set(LUA_VERSION_PATCH "${Lua_VERSION_PATCH}")
endif()
