get_filename_component(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

if(NOT LIBGO_FIND_COMPONENTS)
    set(LIBGO_FIND_COMPONENTS libgo libgo)
    if(LIBGO_FIND_REQUIRED)
        set(LIBGO_FIND_REQUIRED_libgo TRUE)
    endif()

    set(LIBGO_FOUND TRUE)
endif()

set(LIBGO_INCLUDE_DIRS ${_DIR}/../../include)
set(LIBGO_LIBRARIES ${_DIR}/../../lib/liblibgo.a)

