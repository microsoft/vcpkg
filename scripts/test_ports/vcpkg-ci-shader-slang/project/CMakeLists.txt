cmake_minimum_required(VERSION 3.25)
project(shader-slang-test)

find_package(slang CONFIG REQUIRED)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

execute_process(
    COMMAND "${SLANGC_EXECUTABLE}" -v
    COMMAND_ERROR_IS_FATAL ANY
)

add_custom_target(run-slang ALL
    COMMAND slang::slangc -v
)
