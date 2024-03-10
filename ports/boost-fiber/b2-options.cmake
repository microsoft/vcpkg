if(CMAKE_SCRIPT_MODE_FILE)
    return()
endif()

if("numa" IN_LIST FEATURES)
    list(APPEND B2_OPTIONS numa=on)
endif()
