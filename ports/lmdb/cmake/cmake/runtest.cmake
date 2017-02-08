file(MAKE_DIRECTORY testb)
execute_process(COMMAND ${TEST})
file(REMOVE_RECURSE testdb)