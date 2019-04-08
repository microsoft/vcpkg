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
   set(LIBLZMA_LIBRARIES
      \$<\$<NOT:\$<CONFIG:DEBUG>>:${LIBLZMA_LIBRARY_RELEASE}>\$<\$<CONFIG:DEBUG>:${LIBLZMA_LIBRARY_DEBUG}>)
   set(LIBLZMA_LIBRARY ${LIBLZMA_LIBRARY_RELEASE})
endif ()
