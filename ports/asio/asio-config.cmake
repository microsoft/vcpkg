include ("${CMAKE_CURRENT_LIST_DIR}/asio-targets.cmake")

if(NOT TARGET asio::asio)
    add_library(asio::asio INTERFACE IMPORTED)
    target_link_libraries(asio::asio INTERFACE asio)
endif()

get_target_property(_ASIO_INCLUDE_DIR asio INTERFACE_INCLUDE_DIRECTORIES)
set(ASIO_INCLUDE_DIR "${_ASIO_INCLUDE_DIR}")
