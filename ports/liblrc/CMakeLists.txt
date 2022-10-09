project(LRCTools  
        LANGUAGES   CXX   
)

cmake_minimum_required(VERSION 3.2.0)

SET(LRCTOOLS_SRC
    ${CMAKE_SOURCE_DIR}/liblrc/lrc_parser.cc
    ${CMAKE_SOURCE_DIR}/liblrc/lyrics.cc
    ${CMAKE_SOURCE_DIR}/liblrc/utils.cc
)
set(LRCTOOLS_HEADERS
    ${CMAKE_SOURCE_DIR}/liblrc/lrc_parser.h
    ${CMAKE_SOURCE_DIR}/liblrc/lyrics.h
    ${CMAKE_SOURCE_DIR}/liblrc/utils.h
)

add_library(liblrc
    ${LRCTOOLS_SRC}
)

target_include_directories(liblrc
PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
install(
    FILES ${LRCTOOLS_HEADERS}
    DESTINATION include)

install(TARGETS liblrc
    EXPORT unofficial-liblrcConfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-liblrcConfig
    NAMESPACE unofficial::
    DESTINATION share/unofficial-liblrcConfig
)