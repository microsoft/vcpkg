set(REQUIRES )
foreach(ARG IN_LISTS ${ARGS})
    if (ARG STREQUAL "REQUIRED")
        set(REQUIRES "REQUIRED")
    endif()
endforeach()

_find_package(unofficial-tree-sitter CONFIG ${REQUIRES})

list(APPEND TREE_SITTER_LIBRARIES tree-sitter)

set(TREE_SITTER_FOUND 1)
