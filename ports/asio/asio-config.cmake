include ("${CMAKE_CURRENT_LIST_DIR}/asio-targets.cmake")
add_library(asio::asio INTERFACE IMPORTED)
target_link_libraries(asio::asio INTERFACE asio)

get_target_property(_ASIO_INCLUDE_DIR asio INTERFACE_INCLUDE_DIRECTORIES)
set(ASIO_INCLUDE_DIR "${_ASIO_INCLUDE_DIR}")
