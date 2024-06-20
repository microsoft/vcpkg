if(MSVC)
    find_package(unofficial-getopt-win32 CONFIG REQUIRED)
    set(GETOPT_LIBRARY "unofficial::getopt-win32::getopt" CACHE INTERNAL "vcpkg")
    set(GETOPT_RUNTIME_LIBRARY "unused" CACHE INTERNAL "vcpkg")
endif()

if(MINGW AND BUILD_SHARED_LIBS AND NOT CMAKE_CROSSCOMPILING)
    # Prevent running `configure_plugins.cmake`.
    set(CMAKE_CROSSCOMPILING 1)
endif()
