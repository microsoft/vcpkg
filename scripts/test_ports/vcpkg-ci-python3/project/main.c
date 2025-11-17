#include <Python.h>

int main()
{
    PyConfig config;
    PyConfig_InitPythonConfig(&config);
    config.write_bytecode = 0;
    PyConfig_SetString(&config, &config.program_name, L"test");

    PyStatus status = Py_InitializeFromConfig(&config);
    if (PyStatus_Exception(status)) {
        PyConfig_Clear(&config);
        Py_ExitStatusException(status);
    }

    Py_FinalizeEx();
    PyConfig_Clear(&config);
    return 0;
}
