find_package(PkgConfig REQUIRED)

# Legacy variables

message(STATUS "MIMALLOC_INCLUDE_DIR: ${MIMALLOC_INCLUDE_DIR}")
message(STATUS "MIMALLOC_LIBRARY_DIR: ${MIMALLOC_LIBRARY_DIR}")
find_file(mimalloc_h NAMES mimalloc.h PATHS "${MIMALLOC_INCLUDE_DIR}" NO_DEFAULT_PATH REQUIRED)
set(names
    mimalloc
    mimalloc-secure
    mimalloc-static
    mimalloc-static-secure
    mimalloc-debug
    mimalloc-secure-debug
    mimalloc-static-debug
    mimalloc-static-secure-debug
)
find_library(mimalloc_lib NAMES ${names} PATHS "${MIMALLOC_LIBRARY_DIR}" NO_DEFAULT_PATH REQUIRED)

# pkgconfig

pkg_check_modules(PC_MIMALLOC mimalloc IMPORTED_TARGET REQUIRED)

add_executable(pkgconfig-override $<IF:$<BOOL:${BUILD_SHARED_LIBS}>,main-override.c,main-override-static.c>)
target_link_libraries(pkgconfig-override PRIVATE PkgConfig::PC_MIMALLOC)

add_executable(pkgconfig-override-cxx main-override.cpp)
# Order matters at runtime, cf.
# https://github.com/microsoft/mimalloc/blob/dev/readme.md#dynamic-override-on-windows
# but CMake seems offers little control, just interface link libs.
pkg_check_modules(PC_MIMALLOC_FOR_OVERRIDE mimalloc IMPORTED_TARGET REQUIRED)
target_link_libraries(pkgconfig-override-cxx PRIVATE PkgConfig::PC_MIMALLOC_FOR_OVERRIDE)
set_property(TARGET PkgConfig::PC_MIMALLOC_FOR_OVERRIDE APPEND PROPERTY INTERFACE_LINK_LIBRARIES mimalloc-test-override-dep)

# Runtime

if(NOT CMAKE_CROSSCOMPILING)
    if(BUILD_SHARED_LIBS)
        add_custom_target(run-dynamic-override ALL COMMAND $<TARGET_NAME:dynamic-override>)
        add_custom_target(run-dynamic-override-cxx ALL COMMAND $<TARGET_NAME:dynamic-override-cxx>)
        add_custom_target(run-pkgconfig-override-cxx ALL COMMAND $<TARGET_NAME:pkgconfig-override-cxx>)
    else()
        add_custom_target(run-static-override ALL COMMAND $<TARGET_NAME:static-override>)
        if(NOT WIN32 OR EXPECTED_FAILURE_DUE_TO_STATIC_CRT)
            add_custom_target(run-static-override-cxx ALL COMMAND $<TARGET_NAME:static-override-cxx>)
            add_custom_target(run-pkgconfig-override-cxx ALL COMMAND $<TARGET_NAME:pkgconfig-override-cxx>)
        endif()
    endif()
endif()

# Deployment

install(TARGETS pkgconfig-override-cxx)
