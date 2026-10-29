cmake_minimum_required(VERSION 3.19)

project(quirc C)

add_library(quirc
    lib/decode.c
    lib/identify.c
    lib/quirc.c
    lib/version_db.c
    lib/quirc.h
)

target_include_directories(quirc INTERFACE $<INSTALL_INTERFACE:include>)

install(TARGETS quirc
        EXPORT quirc-targets
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib)

install(FILES lib/quirc.h DESTINATION include)

install(EXPORT quirc-targets
    FILE quirc-config.cmake
    NAMESPACE quirc::
    DESTINATION share/quirc
)
