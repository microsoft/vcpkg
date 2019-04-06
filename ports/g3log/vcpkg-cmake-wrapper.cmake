_find_package(${ARGS})

if (G3LOG_FOUND)
    find_package(Threads REQUIRED)

    list(APPEND G3LOG_LIBRARIES Threads::Threads)

    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        list(APPEND G3LOG_LIBRARIES
            DbgHelp.lib
        )
    endif()
endif ()
