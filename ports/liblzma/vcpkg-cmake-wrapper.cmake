message("-- liblzma wrapper: ${ARGS}")
_find_package(${ARGS})

find_library(LIBLZMA_LIBRARY_RELEASE 
             lzma
             PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib 
             NO_DEFAULT_PATH)
find_library(LIBLZMA_LIBRARY_DEBUG 
             lzma
             PATHS ${CMAKE_CURRENT_LIST_DIR}/../../debug/lib 
             NO_DEFAULT_PATH)

if (LIBLZMA_LIBRARY_RELEASE)
   message("-- resetting liblzma libraries: ${LIBLZMA_LIBRARY_RELEASE}")
   set(LIBLZMA_LIBRARIES optimized ${LIBLZMA_LIBRARY_RELEASE} debug ${LIBLZMA_LIBRARY_DEBUG})
   set(LIBLZMA_LIBRARY ${LIBLZMA_LIBRARY_RELEASE})
endif ()