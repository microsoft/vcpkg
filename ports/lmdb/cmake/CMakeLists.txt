cmake_minimum_required(VERSION 3.27)

project(lmdb)

option(LMDB_BUILD_TOOLS "Build lmdb tools" OFF)

include(GNUInstallDirs)

add_library(lmdb
    mdb.c
    midl.c
    module.c
)
if(WIN32 AND BUILD_SHARED_LIBS)
    target_sources(lmdb PRIVATE lmdb.def)
endif()

set(THREADS_PREFER_PTHREAD_FLAG 1)
find_package(Threads REQUIRED)
target_link_libraries(lmdb PRIVATE Threads::Threads ${CMAKE_DL_LIBS})

install(TARGETS lmdb
    EXPORT unofficial-lmdb-targets
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

install(FILES lmdb.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
target_include_directories(lmdb INTERFACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/unofficial-lmdb-config.cmakein" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lmdb-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-lmdb"
)
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-lmdb-config-version.cmake"
    VERSION "${LMDB_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lmdb-config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lmdb-config-version.cmake"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-lmdb"
)
install(EXPORT unofficial-lmdb-targets
    NAMESPACE unofficial::lmdb::
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-lmdb"
)

set(PKGCONFIG_LIBS "")
set(PKGCONFIG_LIBS_PRIVATE "")
if(CMAKE_USE_PTHREADS_INIT)
    string(APPEND PKGCONFIG_LIBS " -pthread")
endif()
if(CMAKE_DL_LIBS STREQUAL "dl")
    string(APPEND PKGCONFIG_LIBS_PRIVATE " -ldl")
endif()
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/lmdb.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/lmdb.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/lmdb.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

if(LMDB_BUILD_TOOLS)
    set(getopt_libs "")
    if(WIN32 AND NOT MINGW)
        find_package(unofficial-getopt-win32 REQUIRED)
        set(getopt_libs "unofficial::getopt-win32::getopt")
    endif()
    foreach(tool IN ITEMS mdb_copy mdb_drop mdb_dump mdb_load mdb_stat)
        add_executable(${tool} ${tool}.c)
        target_link_libraries(${tool} lmdb ${getopt_libs})
        install(TARGETS ${tool}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        )
    endforeach()
endif()
