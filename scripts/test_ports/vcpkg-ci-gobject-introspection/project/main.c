#include <girepository.h>

int main()
{
    GError *error = NULL;

    GIRepository *repository = g_irepository_get_default();
    g_irepository_require(repository, "HarfBuzz", "0.0", 0, &error);
    if (error)
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    GIBaseInfo *base_info = g_irepository_find_by_name(repository, "HarfBuzz", "color_get_red");
    if (!base_info)
    {
        g_error("ERROR: %s\n", "Could not find HarfBuzz.color_get_red");
        return 1;
    }

    // https://harfbuzz.github.io/harfbuzz-hb-ot-color.html#HB-COLOR:CAPS
    // https://harfbuzz.github.io/harfbuzz-hb-ot-color.html#hb-color-t
    GIArgument in_args[1];
    in_args[0].v_uint32 = 0x00001200;  // BGRA read 0x12

    GIArgument retval;
    if (!g_function_info_invoke((GIFunctionInfo *)base_info, (const GIArgument *)&in_args, 1, NULL, 0, &retval, &error))
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    if (retval.v_uint8 != 0x12)
    {
        g_error("ERROR: Expect: 0x12, actual: %0xd\n", retval.v_uint8);
        return 1;
    }

    g_base_info_unref(base_info);

    return 0;
}
