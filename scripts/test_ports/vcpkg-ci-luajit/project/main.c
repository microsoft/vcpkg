#include <stdio.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <luajit.h>

static const int LUAJIT_SETMODE_SUCCESS = 1;

#

int main()
{
    /* FAQ, https://luajit.org/faq.html
     * "Make sure you use luaL_newstate. Avoid using lua_newstate ..."
     * "Make sure you use luaL_openlibs and not ... luaopen_base etc. directly."
     */
    lua_State* L = luaL_newstate();
    if (L == NULL) {
        printf("luaL_newstate failed\n");
        return 2;
    }

    luaL_openlibs(L);

    /* API Extensions, https://luajit.org/ext_c_api.html */
    int result = luaJIT_setmode(L, 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_FLUSH);
    if (result != LUAJIT_SETMODE_SUCCESS) {
        printf("luaJIT_setmode failed\n");        
    }
    else if (luaL_dostring(L, "print('luaJIT_setmode succeeded')\nprint(package.path)") == LUA_OK) {
        lua_pop(L, lua_gettop(L));
    }

    lua_close(L);

    return result == LUAJIT_SETMODE_SUCCESS ? 0 : 1;
}
