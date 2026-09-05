find_package(Threads)

include("${CMAKE_CURRENT_LIST_DIR}/asio-targets.cmake")

if(NOT TARGET asio)
    add_library(asio ALIAS asio::asio)
endif()

get_target_property(ASIO_INCLUDE_DIR asio::asio INTERFACE_INCLUDE_DIRECTORIES)
