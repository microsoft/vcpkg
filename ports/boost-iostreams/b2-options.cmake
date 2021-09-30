list(APPEND B2_OPTIONS
    -sZLIB_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    -sBZIP2_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    -sLZMA_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    -sZSTD_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(lib_suffix lib)
else()
    set(lib_suffix debug/lib)
    if(WIN32)
        set(ZLIB_NAME zlibd)
    else()
        set(ZLIB_NAME z)
    endif()
    list(APPEND B2_OPTIONS
        -sZLIB_NAME=${ZLIB_NAME}
        -sBZIP2_NAME=bz2d
        -sLZMA_NAME=lzmad
        -sZSTD_BINARY=zstdd
    )
endif()

list(APPEND B2_OPTIONS
    -sZLIB_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_suffix}"
    -sBZIP2_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_suffix}"
    -sLZMA_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_suffix}"
    -sZSTD_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_suffix}"
)
