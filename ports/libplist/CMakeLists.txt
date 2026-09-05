cmake_minimum_required(VERSION 3.15)
project(libplist C CXX)

option(BUILD_TOOLS "Build tools." OFF)

include(GNUInstallDirs)

file(GLOB_RECURSE LIBCNARY_SOURCE libcnary/node.c libcnary/node_list.c)
file(GLOB_RECURSE LIBPLIST_SOURCE src/*.c)
file(GLOB_RECURSE LIBPLISTPP_SOURCE src/*.cpp)

set(DEFINITIONS)

list(APPEND DEFINITIONS -DPACKAGE_VERSION="${PACKAGE_VERSION}")

if(BUILD_SHARED_LIBS)
    if(WIN32)
        list(APPEND DEFINITIONS -DLIBPLIST_EXPORT)
    endif()
else()
    list(APPEND DEFINITIONS -DLIBPLIST_STATIC)
endif()

if(UNIX)
    list(APPEND DEFINITIONS -DHAVE_STRNDUP)
endif()

if(WIN32)
    list(APPEND DEFINITIONS -D_CRT_SECURE_NO_WARNINGS)
endif()

add_library(libplist ${LIBPLIST_SOURCE} ${LIBCNARY_SOURCE})
target_include_directories(libplist PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/libcnary/include>"
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>"
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libplist PRIVATE ${DEFINITIONS})
set_target_properties(libplist PROPERTIES OUTPUT_NAME plist-2.0)
if(UNIX AND NOT APPLE)
    target_link_libraries(libplist PRIVATE m)
endif()

add_library(libplist++ STATIC ${LIBPLISTPP_SOURCE} ${LIBCNARY_SOURCE})
target_include_directories(libplist++ PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/libcnary/include>"
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>"
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(libplist++ PRIVATE ${DEFINITIONS})
target_link_libraries(libplist++ PUBLIC libplist)
set_target_properties(libplist++ PROPERTIES OUTPUT_NAME plist++-2.0)

install(TARGETS libplist libplist++ EXPORT unofficial-libplist)

install(
    EXPORT unofficial-libplist
    FILE unofficial-libplist-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-libplist"
    NAMESPACE unofficial::libplist::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/include/plist"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

set(PACKAGE_NAME libplist)
set(PACKAGE_VERSION 2.0)
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")

foreach(PLIST_PKGCONFIG libplist-2.0.pc libplist++-2.0.pc)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/src/${PLIST_PKGCONFIG}.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}"
        @ONLY
    )
    install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${PLIST_PKGCONFIG}"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
    )
endforeach()

if(BUILD_TOOLS)
    add_executable(plistutil "tools/plistutil.c")
    target_compile_definitions(plistutil PRIVATE
        -DPACKAGE_VERSION="2.3.0"
        -DPACKAGE_URL="https://github.com/libimobiledevice/libplist"
        -DPACKAGE_BUGREPORT="https://github.com/libimobiledevice/libplist/issues"
    )
    if(NOT BUILD_SHARED_LIBS)
        target_compile_definitions(plistutil PRIVATE -DLIBPLIST_STATIC)
    endif()
    target_link_libraries(plistutil PRIVATE libplist)

    install(
        TARGETS plistutil
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    )
endif()
