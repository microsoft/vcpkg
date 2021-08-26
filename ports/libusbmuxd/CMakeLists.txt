cmake_minimum_required(VERSION 3.0)
project(libusbmuxd C)

# find dependencies
find_path(libplist_INCLUDES plist.h PATH_SUFFIXES plist)
set(libplist_INCLUDES ${libplist_INCLUDES}/../)
find_library(libplist NAMES plist libplist plist-2.0 libplist-2.0 REQUIRED)

# ready to create library
file(GLOB_RECURSE IDVCACTV_TOOLS_HDR common/*.h)
file(GLOB_RECURSE IDVCACTV_TOOLS_SRC common/*.c)

file(GLOB_RECURSE IDVCACTV_PUBLIC_HDR include/*.h)
file(GLOB_RECURSE IDVCACTV_SRC src/*.c)

add_library(libusbmuxd ${IDVCACTV_TOOLS_HDR} ${IDVCACTV_TOOLS_SRC} ${IDVCACTV_SRC} ${IDVCACTV_PUBLIC_HDR})
target_include_directories(libusbmuxd PRIVATE ${libplist_INCLUDES} include common)
target_compile_definitions(libusbmuxd PRIVATE -DPACKAGE_STRING="1.2.77")
if (WIN32)
    target_compile_definitions(libusbmuxd PRIVATE -DWIN32)
    target_link_libraries(libusbmuxd PRIVATE Ws2_32)
endif()
target_link_libraries(libusbmuxd PRIVATE ${libplist})

# install
install(
    TARGETS libusbmuxd
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

set(LIBPLIST_VERSION 2.0)
set(PACKAGE_NAME libusbmuxd)
set(PACKAGE_VERSION 2.0)
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix \${prefix})
set(libdir \${prefix}/lib)
set(includedir \${prefix}/../include)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libusbmuxd-2.0.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc
    @ONLY
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libusbmuxd-2.0.pc
    DESTINATION lib/pkgconfig
)

install(FILES ${IDVCACTV_PUBLIC_HDR} DESTINATION include)