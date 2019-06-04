include ("${CMAKE_CURRENT_LIST_DIR}/asio-targets.cmake")
add_library(asio::asio INTERFACE IMPORTED)
target_link_libraries(asio::asio INTERFACE asio)
