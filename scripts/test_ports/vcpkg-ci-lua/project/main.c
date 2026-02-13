#include <stdio.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main()
{
    lua_State* L = luaL_newstate();
    if (L == NULL) {
        printf("luaL_newstate failed\n");
        return 2;
    }

    luaL_openlibs(L);

    if (luaL_dostring(L, "print(package.path)") == LUA_OK) {
        lua_pop(L, lua_gettop(L));
    }

    lua_close(L);
    return 0;
}
