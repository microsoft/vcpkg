cmake_minimum_required(VERSION 3.8)
project(asio)

add_library(asio INTERFACE)

# Export target
install(TARGETS asio
    EXPORT asio
    INCLUDES DESTINATION include/
)

install(EXPORT asio
    DESTINATION "share/asio"
    FILE asio-targets.cmake
)

install(DIRECTORY
    asio/include/asio
    DESTINATION include/
    FILES_MATCHING
        PATTERN "*.hpp"
        PATTERN "*.ipp"
)

install(FILES
    asio/include/asio.hpp
    DESTINATION include/
)
