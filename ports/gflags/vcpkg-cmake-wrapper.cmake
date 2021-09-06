set(GFLAGS_USE_TARGET_NAMESPACE ON)

_find_package(${ARGS})

foreach(tgt gflags gflags_shared gflags_static)
    if (NOT TARGET ${tgt} AND TARGET "gflags::${tgt}")
        set_target_properties("gflags::${tgt}" PROPERTIES IMPORTED_GLOBAL TRUE)
        add_library(${tgt} ALIAS "gflags::${tgt}")
    endif() 
endforeach(tgt)
