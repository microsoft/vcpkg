set(GFLAGS_USE_TARGET_NAMESPACE ON)

_find_package(${ARGS})

foreach(tgt gflags gflags_shared gflags_static)
    if (NOT TARGET ${tgt} AND TARGET "gflags::${tgt}")
        add_library(${tgt} ALIAS "gflags::${tgt}")
    endif() 
endforeach(tgt)
