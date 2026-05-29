find_package(BLAS REQUIRED)
set(BLA_SIZEOF_INTEGER 4)
set(SuiteSparse_BLAS_integer int32_t)

if(WIN32)
    # OpenBLAS includes an underscore suffix on Windows for all of its symbols.
    # This is not detected automatically by SuiteSparse or FindBLAS and needs to be set manually.
    add_compile_definitions(BLAS64__SUFFIX=_)
endif()
