if(MINGW AND BUILD_SHARED_LIBS AND NOT CMAKE_CROSSCOMPILING)
    # Prevent running `configure_plugins.cmake`.
    set(CMAKE_CROSSCOMPILING 1)
endif()
