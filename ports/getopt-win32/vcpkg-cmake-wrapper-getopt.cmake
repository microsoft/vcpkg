_find_package(getopt-win32)
set(getopt_INCLUDE_DIR "${getopt-win32_INCLUDE_DIR}")
set(getopt_LIBRARY "${getopt-win32_LIBRARY}")
set(getopt_LIBRARIES "${getopt-win32_LIBRARY}")

if(getopt-win32_FOUND)
    set(getopt_FOUND TRUE)

    add_library(getopt ALIAS getopt-win32)
endif()
