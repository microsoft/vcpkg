_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    list(APPEND ARROW_LIBRARIES arrow_static)
    list(APPEND PARQUET_LIBRARIES parquet_static)
else()
    list(APPEND ARROW_LIBRARIES arrow_shared)
    list(APPEND PARQUET_LIBRARIES parquet_shared)
endif()
