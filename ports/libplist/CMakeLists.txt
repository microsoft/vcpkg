cmake_minimum_required(VERSION 3.8)
project(plist C CXX)

file(GLOB_RECURSE PLIST_HEADER include/plist/*.h)

set(PLIST_SRC
    src/base64.c
    src/bytearray.c
    src/hashtable.c
    src/ptrarray.c
    src/time64.c
    src/xplist.c
    src/bplist.c
    src/plist.c
)

set(PLISTPP_SRC
    src/Node.cpp
    src/Structure.cpp
    src/Array.cpp
    src/Boolean.cpp
    src/Data.cpp
    src/Date.cpp
    src/Dictionary.cpp
    src/Integer.cpp
    src/Key.cpp
    src/Real.cpp
    src/String.cpp
    src/Uid.cpp
)

file(GLOB_RECURSE LIBCNARY_HEADER libcnary/include/*.h)
file(GLOB_RECURSE LIBCNARY_SRC libcnary/*c)

add_library(plist ${PLIST_SRC} ${PLIST_HEADER} ${LIBCNARY_SRC} ${LIBCNARY_HEADER})
target_include_directories(plist PRIVATE src include libcnary/include)
set_target_properties(plist PROPERTIES OUTPUT_NAME plist-2.0)

add_library(plist++ STATIC ${PLISTPP_SRC} ${PLIST_HEADER} ${LIBCNARY_SRC} ${LIBCNARY_HEADER})
set_target_properties(plist++ PROPERTIES OUTPUT_NAME plist++-2.0)
target_include_directories(plist++ PRIVATE src include libcnary/include)

if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_options(plist PRIVATE -W3 -WX- -sdl-)
    target_compile_definitions(plist PRIVATE -DLIBPLIST_EXPORTS)
    target_compile_options(plist++ PRIVATE -W3 -WX- -sdl-)
    target_compile_definitions(plist++ PRIVATE -DLIBPLIST_EXPORTS)
endif()
target_link_libraries(plist++ PRIVATE plist)

install(
    TARGETS plist plist++
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

set(PACKAGE_NAME libplist)
set(PACKAGE_VERSION 2.0)
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix \${prefix})
set(libdir \${prefix}/lib)
set(includedir \${prefix}/../include)
foreach (PLIST_PKGCONFIG libplist-2.0.pc libplist++-2.0.pc)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/${PLIST_PKGCONFIG}.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}
    @ONLY
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}
    DESTINATION lib/pkgconfig)
endforeach()

install(FILES ${PLIST_HEADER} DESTINATION include/plist)
