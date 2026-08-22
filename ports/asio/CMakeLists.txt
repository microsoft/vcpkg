cmake_minimum_required(VERSION 3.10)
project(asio)

add_library(asio INTERFACE)

find_package(Threads)
if(Threads_FOUND)
    target_link_libraries(asio INTERFACE Threads::Threads)
endif()

# Export target
install(TARGETS asio
    EXPORT asio
    INCLUDES DESTINATION include/
)

install(EXPORT asio
    DESTINATION "share/asio"
    FILE asio-targets.cmake
    NAMESPACE asio::
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

set(exec_prefix [[${prefix}]])
set(package_name [[asio]])
configure_file(asio/asio.pc.in "${PROJECT_BINARY_DIR}/asio.pc" @ONLY)
install(FILES "${PROJECT_BINARY_DIR}/asio.pc" DESTINATION share/pkgconfig)
