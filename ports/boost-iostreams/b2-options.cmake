if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(lib_path_suffix lib)
else()
    set(lib_path_suffix debug/lib)
endif()

if("bzip2" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS
        -sBZIP2_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    )
    # Overwride debug library name
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND B2_OPTIONS
            -sBZIP2_NAME=bz2d
        )
    endif()
    list(APPEND B2_OPTIONS
        -sBZIP2_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_path_suffix}"
    )
else()
    list(APPEND B2_OPTIONS
        -sNO_BZIP2=1
    )
endif()

if("lzma" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS
        -sLZMA_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    )
    # Overwride debug library name
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND B2_OPTIONS
            -sLZMA_NAME=lzmad
        )
    endif()
    list(APPEND B2_OPTIONS
        -sLZMA_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_path_suffix}"
    )
else()
    list(APPEND B2_OPTIONS
        -sNO_LZMA=1
    )
endif()

if("zlib" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS
        -sZLIB_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    )
    # Overwride debug library name
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        if(WIN32)
            set(ZLIB_NAME zlibd)
        else()
            set(ZLIB_NAME z)
        endif()
        list(APPEND B2_OPTIONS
            -sZLIB_NAME=${ZLIB_NAME}
        )
    endif()
    list(APPEND B2_OPTIONS
        -sZLIB_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_path_suffix}"
    )
else()
    list(APPEND B2_OPTIONS
        -sNO_ZLIB=1
    )
endif()

if("zstd" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS
        -sZSTD_INCLUDE="${CURRENT_INSTALLED_DIR}/include"
    )
    list(APPEND B2_OPTIONS
        -sZSTD_LIBRARY_PATH="${CURRENT_INSTALLED_DIR}/${lib_path_suffix}"
    )
else()
    list(APPEND B2_OPTIONS
        -sNO_ZSTD=1
    )
endif()