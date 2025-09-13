#include <Python.h>

int main()
{
    PyConfig config;
    PyConfig_InitIsolatedConfig(&config);
    config.optimization_level = 2;
    config.write_bytecode = 0;
    config.user_site_directory = 0;
    PyConfig_SetString(&config, &config.program_name, L"test");
    config.user_site_directory = 0;

#ifdef BATTERIES
    PyWideStringList_Append(&config.module_search_paths, BATTERIES);
    config.module_search_paths_set = 1;
#endif

    PyStatus status = Py_InitializeFromConfig(&config);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        Py_ExitStatusException(status);
    }

    Py_FinalizeEx();
    PyConfig_Clear(&config);
    return 0;
}
