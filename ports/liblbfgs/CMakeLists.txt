cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
PROJECT(liblbfgs)
                          
file(GLOB SOURCE_FILE
	"lib/*.c"
)
file(GLOB HEADERS_FILE
	"include/*.h"
        "lib/*.h"
)
include_directories("include")
add_library (lbfgs STATIC ${SOURCE_FILE} ${HEADERS_FILE})

install(TARGETS lbfgs
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)


install(FILES ${HEADERS_FILE} DESTINATION include)