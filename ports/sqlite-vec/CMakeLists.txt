cmake_minimum_required(VERSION 3.20)
project(sqlite-vec VERSION 0.1.9 LANGUAGES C)

include(GNUInstallDirs)

find_package(unofficial-sqlite3 CONFIG REQUIRED)

set(VERSION "${PROJECT_VERSION}")
set(VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(DATE "")
set(SOURCE "")
configure_file(sqlite-vec.h.tmpl "${CMAKE_CURRENT_BINARY_DIR}/sqlite-vec.h")

add_library(sqlite-vec sqlite-vec.c)
target_include_directories(sqlite-vec
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}"
    INTERFACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(sqlite-vec PRIVATE SQLITE_CORE SQLITE_VEC_STATIC)
target_link_libraries(sqlite-vec PUBLIC unofficial::sqlite3::sqlite3)
find_library(MATH_LIBRARY m)
if(MATH_LIBRARY)
    target_link_libraries(sqlite-vec PRIVATE m)
endif()

install(TARGETS sqlite-vec EXPORT unofficial-sqlite-vec-targets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sqlite-vec.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(EXPORT unofficial-sqlite-vec-targets
    NAMESPACE unofficial::sqlite-vec::
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-sqlite-vec"
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sqlite-vec-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(unofficial-sqlite3 CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-sqlite-vec-targets.cmake")
]])
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-sqlite-vec-config.cmake"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-sqlite-vec"
)
