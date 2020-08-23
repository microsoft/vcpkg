cmake_minimum_required(VERSION 3.8)
project(plist C)

file(GLOB_RECURSE PLIST_HEADER include/plist/*.h)
file(GLOB_RECURSE PLIST_SRC src/*.c)

file(GLOB_RECURSE LIBCNARY_HEADER libcnary/include/*.h)
file(GLOB_RECURSE LIBCNARY_SRC libcnary/*c)

add_library(plist ${PLIST_SRC} ${PLIST_HEADER} ${LIBCNARY_SRC} ${LIBCNARY_HEADER})
target_include_directories(plist PRIVATE src include libcnary/include)

if(WIN32)
    target_compile_options(plist PRIVATE -W3 -WX- -sdl-)
    target_compile_definitions(plist PRIVATE -DLIBPLIST_EXPORTS)
endif()

install(
    TARGETS plist
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libplist.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libplist.pc
    @ONLY
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libplist.pc
    DESTINATION lib/pkgconfig)

install(FILES ${PLIST_HEADER} DESTINATION include/plist)