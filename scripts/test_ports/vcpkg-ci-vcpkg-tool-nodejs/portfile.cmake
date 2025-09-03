set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

find_program(NODEJS
    NAMES node
    PATHS
        "${CURRENT_INSTALLED_DIR}/tools/node"
        "${CURRENT_INSTALLED_DIR}/tools/node/bin"
    NO_DEFAULT_PATH
    REQUIRED
)
execute_process(
    COMMAND "${NODEJS}" --version
    COMMAND_ECHO STDOUT
    COMMAND_ERROR_IS_FATAL ANY
)
execute_process(
    COMMAND "${NODEJS}" -p "process.arch"
    COMMAND_ECHO STDOUT
    COMMAND_ERROR_IS_FATAL ANY
)
