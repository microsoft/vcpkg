cmake_minimum_required(VERSION 3.27)

project(lmdb)

option(LMDB_BUILD_TOOLS "Build lmdb tools" OFF)
option(LMDB_BUILD_TESTS "Build lmdb tests" OFF)
option(LMDB_INSTALL_HEADERS "Install LMDB header files" ON)

include(GNUInstallDirs)

add_library(lmdb mdb.c lmdb.h midl.c midl.h)
if(WIN32 AND BUILD_SHARED_LIBS)
    target_sources(lmdb PRIVATE lmdb.def)
endif()

set(THREADS_PREFER_PTHREAD_FLAG 1)
find_package(Threads REQUIRED)
target_link_libraries(lmdb PRIVATE Threads::Threads)

install(TARGETS lmdb
    EXPORT unofficial-lmdb-targets
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

if(LMDB_INSTALL_HEADERS)
    install(FILES lmdb.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
endif()
target_include_directories(lmdb INTERFACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

include(CMakePackageConfigHelpers)
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/package-config.cmakein" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lmdb-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/lmdb"
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

if(LMDB_BUILD_TOOLS)
    set(getopt_libs "")
    if(WIN32 AND NOT MINGW)
        find_package(unofficial-getopt-win32 REQUIRED)
        set(getopt_libs "unofficial::getopt-win32::getopt")
    endif()
    foreach(tool IN ITEMS mdb_copy mdb_dump mdb_load mdb_stat)
        add_executable(${tool} ${tool}.c)
        target_link_libraries(${tool} lmdb ${getopt_libs})
        install(TARGETS ${tool}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        )
    endforeach()
endif()

if(LMDB_BUILD_TESTS)
    enable_testing()
    # mtest6 needs more symbols than provided by some builds of lmdb
    foreach(test IN ITEMS mtest mtest2 mtest3 mtest4 mtest5)
        add_executable(${test} ${test}.c)
        target_link_libraries(${test} lmdb)
        add_test(NAME ${test}
            COMMAND "${CMAKE_COMMAND}" "-DTEST=$<TARGET_FILE:${test}" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/runtest.cmake")
    endforeach()
endif()
