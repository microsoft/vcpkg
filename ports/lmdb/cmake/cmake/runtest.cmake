file(REMOVE_RECURSE testdb)
file(MAKE_DIRECTORY testdb)
execute_process(COMMAND "${TEST}")
