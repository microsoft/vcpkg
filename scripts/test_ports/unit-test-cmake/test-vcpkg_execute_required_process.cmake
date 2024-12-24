# vcpkg_execute_required_process
#[[
        "ALLOW_IN_DOWNLOAD_MODE;OUTPUT_STRIP_TRAILING_WHITESPACE;ERROR_STRIP_TRAILING_WHITESPACE"
        "WORKING_DIRECTORY;LOGNAME;TIMEOUT;OUTPUT_VARIABLE;ERROR_VARIABLE"
        "COMMAND;SAVE_LOG_FILES"
]]

block(SCOPE_FOR VARIABLES)

set(logname "test-vcpkg_execute_required_process")

function(count_log_files out_var)
    set(count 0)
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${logname}-out.log")
        math(EXPR count "${count} + 1")
    endif()
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${logname}-err.log")
        math(EXPR count "${count} + 1")
    endif()
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${logname}-extra.log")
        math(EXPR count "${count} + 1")
    endif()
    set("${out_var}" "${count}" PARENT_SCOPE)
endfunction()

function(reset_log_files)
    file(REMOVE "${CURRENT_BUILDTREES_DIR}/${logname}-out.log")
    file(REMOVE "${CURRENT_BUILDTREES_DIR}/${logname}-err.log")
    file(REMOVE "${CURRENT_BUILDTREES_DIR}/${logname}-extra.log")
endfunction()


# ALLOW_IN_DOWNLOAD_MODE

set(VCPKG_DOWNLOAD_MODE 1)
unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Success
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        ALLOW_IN_DOWNLOAD_MODE
    )]]
)
unit_test_ensure_fatal_error([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Success
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
    )]]
)

set(VCPKG_DOWNLOAD_MODE "")
unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Success
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        ALLOW_IN_DOWNLOAD_MODE
    )]]
)
unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Success
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
    )]]
)


# COMMAND, LOGNAME

reset_log_files()
unit_test_check_variable_equal([[count_log_files(count)]] count 0)

unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Hello world
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
    )]]
)
unit_test_check_variable_equal([[ count_log_files(count) ]] count 2)
unit_test_check_variable_equal([[ file(STRINGS "${CURRENT_BUILDTREES_DIR}/${logname}-out.log" stdout) ]] stdout "Hello world")


# WORKING_DIRECTORY, SAVE_LOG_FILES

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/subdir")
file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/subdir")
file(WRITE "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/source" "extra log")
file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/subdir")

reset_log_files()
unit_test_check_variable_equal([[count_log_files(count)]] count 0)

unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E rename source subdir/extra.log
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir"
        LOGNAME "${logname}"
        SAVE_LOG_FILES "subdir/extra.log"
    )]]
)
unit_test_check_variable_equal([[ count_log_files(count) ]] count 3)
unit_test_check_variable_equal([[ file(STRINGS "${CURRENT_BUILDTREES_DIR}/${logname}-extra.log" extra) ]] extra "extra log")


# OUTPUT_VARIABLE, OUTPUT_STRIP_TRAILING_WHITESPACE

reset_log_files()
unit_test_check_variable_equal([[count_log_files(count)]] count 0)

unit_test_check_variable_equal([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Hello world
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        OUTPUT_VARIABLE outvar
    )]]
    outvar "Hello world\n"
)
unit_test_check_variable_equal([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E echo Hello world
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        OUTPUT_VARIABLE outvar
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )]]
    outvar "Hello world"
)
unit_test_check_variable_equal([[ count_log_files(count) ]] count 2)


# ERROR_VARIABLE

reset_log_files()
unit_test_check_variable_equal([[count_log_files(count)]] count 0)

file(WRITE "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/stderr.cmake" "message(WARNING on-stderr)\n")
unit_test_check_variable_not_equal([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -P "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/stderr.cmake"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        ERROR_VARIABLE outvar
    )
    string(FIND "${outvar}" "on-stderr" pos)
    ]] pos -1
)
unit_test_check_variable_equal([[ count_log_files(count) ]] count 2)


# OUTPUT_VARIABLE == ERROR_VARIABLE

reset_log_files()
unit_test_check_variable_equal([[count_log_files(count)]] count 0)

file(WRITE "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/combined.cmake" [[
    message(WARNING on-stderr)
    message(STATUS on-stdout)
]])
unit_test_check_variable_not_equal([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -P "${CURRENT_BUILDTREES_DIR}/vcpkg_execute_required_process-dir/combined.cmake"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        OUTPUT_VARIABLE outvar
        ERROR_VARIABLE outvar
    )
    string(REGEX MATCH "on-stderr.*on-stdout" match "${outvar}")
    ]] CMAKE_MATCH_0 ""
)
unit_test_check_variable_equal([[ count_log_files(count) ]] count 2)


# TIMEOUT (if not flaky)

unit_test_ensure_fatal_error([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E sleep 10
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "${logname}"
        TIMEOUT 1
    )]]
)


endblock()
