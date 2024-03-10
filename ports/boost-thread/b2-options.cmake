if(CMAKE_SCRIPT_MODE_FILE)
    set(B2_REQUIREMENTS "<library>/boost/date_time//boost_date_time")
    return()
endif()

list(APPEND B2_OPTIONS /boost/thread//boost_thread)
