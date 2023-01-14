set(GFLAGS_USE_TARGET_NAMESPACE ON)

_find_package(${ARGS})

foreach(tgt gflags gflags_shared gflags_static)
    if (NOT TARGET ${tgt} AND TARGET "gflags::${tgt}")
        add_library(${tgt} INTERFACE IMPORTED)
        target_link_libraries(${tgt} INTERFACE "gflags::${tgt}")
    endif() 
endforeach(tgt)
