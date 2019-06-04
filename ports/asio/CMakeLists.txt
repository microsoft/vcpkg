cmake_minimum_required(VERSION 3.8)
project(asio)

add_library(asio INTERFACE)

# Always use "ASIO_STANDALONE" to avoid boost dependency
file(READ "asio/include/asio/detail/config.hpp" _contents)
string(REPLACE "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)" _contents "${_contents}")
file(WRITE "asio/include/asio/detail/config.hpp" "${_contents}")

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
