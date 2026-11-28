add_library(sibling SHARED "${CMAKE_CURRENT_BINARY_DIR}/../main.c")
check_sourcelink(sibling)
