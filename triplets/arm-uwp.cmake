set(CMAKE_SYSTEM_NAME WindowsStore)
set(CMAKE_SYSTEM_VERSION 10.0)

if(NOT CMAKE_GENERATOR MATCHES "Visual Studio 14 2015 ARM")
    message(FATAL_ERROR "Visual Studio Generator must be used to target UWP")
endif()
