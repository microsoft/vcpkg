cmake_minimum_required(VERSION 3.8)
project(plist C CXX)

include(GNUInstallDirs)

file(GLOB_RECURSE PLIST_HEADER include/plist/*.h)

file(GLOB_RECURSE PLIST_SRC src/*.c)

file(GLOB_RECURSE PLISTPP_SRC src/*.cpp)

file(GLOB_RECURSE LIBCNARY_HEADER libcnary/include/*.h)
file(GLOB_RECURSE LIBCNARY_SRC libcnary/*c)

add_library(plist ${PLIST_SRC} ${PLIST_HEADER} ${LIBCNARY_SRC} ${LIBCNARY_HEADER})
add_library(unofficial::libplist::plist ALIAS plist)
target_include_directories(plist PRIVATE src include libcnary/include)
set_target_properties(plist PROPERTIES OUTPUT_NAME plist-2.0)

add_library(plist++ ${PLISTPP_SRC} ${PLIST_HEADER} ${LIBCNARY_SRC} ${LIBCNARY_HEADER})
add_library(unofficial::libplist::plist++ ALIAS plist++)
set_target_properties(plist++ PROPERTIES OUTPUT_NAME plist++-2.0)
target_include_directories(plist++ PRIVATE src include libcnary/include)

if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_options(plist PRIVATE -W3 -WX- -sdl-)
    target_compile_definitions(plist PRIVATE -DLIBPLIST_EXPORTS)
    target_compile_options(plist++ PRIVATE -W3 -WX- -sdl-)
    target_compile_definitions(plist++ PRIVATE -DLIBPLIST_EXPORTS)
endif()
if(UNIX)
    target_compile_definitions(plist PRIVATE -DHAVE_STRNDUP)
    target_compile_definitions(plist++ PRIVATE -DHAVE_STRNDUP)
endif()

target_link_libraries(plist++ PRIVATE plist)

target_include_directories(plist INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_include_directories(plist++ INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
install(TARGETS plist plist++ EXPORT libplist)
install(EXPORT libplist FILE libplist-config.cmake DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/libplist" NAMESPACE unofficial::libplist::)

set(PACKAGE_NAME libplist)
set(PACKAGE_VERSION 2.0)
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "${prefix}")
set(libdir "${prefix}/lib")
set(includedir "${prefix}/include")
foreach (PLIST_PKGCONFIG libplist-2.0.pc libplist++-2.0.pc)
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/${PLIST_PKGCONFIG}.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}"
    @ONLY
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}"
    DESTINATION lib/pkgconfig)
endforeach()

install(FILES ${PLIST_HEADER} DESTINATION include/plist)
