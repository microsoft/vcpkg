#include <girepository.h>
#include <stdio.h>

int main()
{
    GError *error = NULL;

    GIRepository *repository = g_irepository_get_default();
    GSList* paths = g_irepository_get_search_path();
    for (; paths != NULL; paths = paths->next)
        g_message("Search path entry: %s\n", (const char*)paths->data);

    GITypelib *typelib = g_irepository_require(repository, "GIRepository", NULL, 0, &error);
    if (error)
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    GIBaseInfo *base_info = g_irepository_find_by_name(repository, "GIRepository", "get_minor_version");
    if (!base_info)
    {
        g_error("ERROR: %s\n", "Could not find GIRepository get_minor_version");
        return 1;
    }

    GIArgument retval;
    if (!g_function_info_invoke((GIFunctionInfo *)base_info, NULL, 0, NULL, 0, &retval, &error))
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    g_message("GI Repository minor version: %d", retval.v_uint);

    g_base_info_unref(base_info);

    return 0;
}
