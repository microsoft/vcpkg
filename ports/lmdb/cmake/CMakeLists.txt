cmake_minimum_required(VERSION 2.8)

file(READ "${CMAKE_CURRENT_SOURCE_DIR}/lmdb.h" VERSION_HEADER)
string(REGEX MATCH ".*MDB_VERSION_MAJOR[ \t]+([0-9])" MAJOR_VERSION_MATCH "${VERSION_HEADER}")
set(LMDB_MAJOR_VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH ".*MDB_VERSION_MINOR[ \t]+([0-9])" MINOR_VERSION_MATCH "${VERSION_HEADER}")
set(LMDB_MINOR_VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH ".*MDB_VERSION_PATCH[ \t]+([0-9]+)" PATCH_VERSION_MATCH "${VERSION_HEADER}")
set(LMDB_PATCH_VERSION ${CMAKE_MATCH_1})

set(LMDB_VERSION "${LMDB_MAJOR_VERSION}.${LMDB_MINOR_VERSION}.${LMDB_PATCH_VERSION}")

project(lmdb)

option(LMDB_BUILD_TOOLS "Build lmdb tools" OFF)
option(LMDB_BUILD_TESTS "Build lmdb tests" OFF)
option(LMDB_INSTALL_HEADERS "Install LMDB header files" ON)
set(LMDB_INCLUDE_INSTALL_DIR include CACHE PATH "Install directory for headers")
set(LMDB_LIBRARY_INSTALL_DIR lib CACHE PATH "Install directory for library")
set(LMDB_RUNTIME_INSTALL_DIR bin CACHE PATH "Install directory for binaries/dlls")
set(LMDB_CONFIG_INSTALL_DIR share/lmdb CACHE PATH "Install directory for cmake config files")

if(MSVC AND BUILD_SHARED_LIBS)
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /DEF:\"${CMAKE_CURRENT_SOURCE_DIR}/lmdbd.def\"")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /DEF:\"${CMAKE_CURRENT_SOURCE_DIR}/lmdb.def\"")
endif()

set(SRCS lmdb mdb.c lmdb.h midl.c midl.h )
add_library(lmdb ${SRCS})
set_target_properties(lmdb PROPERTIES DEBUG_POSTFIX d)
if (WIN32)
  target_link_libraries(lmdb PRIVATE ntdll.lib)
endif()

install(TARGETS lmdb DESTINATION lib
        EXPORT lmdb-targets
        RUNTIME DESTINATION ${LMDB_RUNTIME_INSTALL_DIR}
        LIBRARY DESTINATION ${LMDB_LIBRARY_INSTALL_DIR}
        ARCHIVE DESTINATION ${LMDB_LIBRARY_INSTALL_DIR}
        )

if(LMDB_INSTALL_HEADERS)
  install(FILES lmdb.h midl.h DESTINATION ${LMDB_INCLUDE_INSTALL_DIR})
endif()

include(CMakePackageConfigHelpers)

set(INSTALL_INCLUDE_DIR ${LMDB_INCLUDE_INSTALL_DIR})
configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/package-config.cmakein ${CMAKE_CURRENT_BINARY_DIR}/lmdb-config.cmake
                              INSTALL_DESTINATION ${LMDB_CONFIG_INSTALL_DIR}
                              PATH_VARS INSTALL_INCLUDE_DIR
                              )

write_basic_package_version_file( ${CMAKE_CURRENT_BINARY_DIR}/lmdb-config-version.cmake VERSION ${LMDB_VERSION} COMPATIBILITY SameMajorVersion )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lmdb-config.cmake ${CMAKE_CURRENT_BINARY_DIR}/lmdb-config-version.cmake
        DESTINATION ${LMDB_CONFIG_INSTALL_DIR} )


install(EXPORT lmdb-targets DESTINATION ${LMDB_CONFIG_INSTALL_DIR})

if(LMDB_BUILD_TOOLS)
  # don't build mdb_dump/load/stat since they will
  # not build on windows
  foreach(_tool mdb_copy)
    add_executable(${_tool} ${_tool}.c)
    target_link_libraries(${_tool} lmdb)
  endforeach()
endif()

if(LMDB_BUILD_TESTS)
  enable_testing()
  # don't use mtest6 since it will only build in static
  # build
  foreach(_test mtest mtest2 mtest3 mtest4 mtest5)
    add_executable(${_test} ${_test}.c)
    target_link_libraries(${_test} lmdb)
    add_test(NAME ${_test}
             COMMAND ${CMAKE_COMMAND} -DTEST=$<TARGET_FILE:"${_test}" -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/runtest.cmake)
  endforeach()
endif()
