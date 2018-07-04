if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../lib/libpng16.a")
    set(PNG_LIBRARY_RELEASE "${CMAKE_CURRENT_LIST_DIR}/../../lib/libpng16.a" CACHE FILEPATH "")
endif()
_find_package(${ARGS})
