file(GLOB SRC
    "*.c"
)

file(GLOB HEADERS
    "*.h"
)

add_library(gettimeofday ${SRC})
target_link_libraries(gettimeofday)

install(TARGETS gettimeofday
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
        )

install(FILES ${HEADERS} DESTINATION include)
