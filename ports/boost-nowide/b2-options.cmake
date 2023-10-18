if(CMAKE_SCRIPT_MODE_FILE)
    return()
endif()

if(APPLE)
    list(APPEND B2_OPTIONS cxxstd=11)
endif()
