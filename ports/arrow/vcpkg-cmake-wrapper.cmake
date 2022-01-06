_find_package(${ARGS})

if(TARGET arrow_static)
    list(APPEND ARROW_LIBRARIES arrow_static)
    list(APPEND PARQUET_LIBRARIES parquet_static)
elseif (TARGET arrow_shared)
    list(APPEND ARROW_LIBRARIES arrow_shared)
    list(APPEND PARQUET_LIBRARIES parquet_shared)
endif()
