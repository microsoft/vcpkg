macro(deferred_tests)

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

if(BUILD_SHARED_LIBS OR NOT WIN32)
    add_executable(pkgconfig-override-cxx main-override.cpp)
    target_link_libraries(pkgconfig-override-cxx PRIVATE PkgConfig::PC_MIMALLOC)
endif()

# overriding allocation in a DLL that is compiled independent of mimalloc
# https://github.com/microsoft/mimalloc/blob/dev/readme.md#dynamic-override-on-windows


if(BUILD_SHARED_LIBS AND WIN32 AND "ci" IN_LIST FEATURES)
    # independent DLL, ide/vs2022/mimalloc-override-test-dep.vcxproj
    add_library(mimalloc-test-override-dep SHARED main-override-dep.cpp)

    # dependent EXE, ide/vs2022/mimalloc-override-test.vcxproj
    add_executable(mimalloc-test-override main-override.cpp)
    target_link_libraries(mimalloc-test-override PRIVATE PkgConfig::PC_MIMALLOC mimalloc-test-override-dep)
endif()

# Runtime

if(NOT CMAKE_CROSSCOMPILING)
    get_directory_property(targets BUILDSYSTEM_TARGETS)
    list(REMOVE_ITEM targets test-wrong)
    foreach(target IN LISTS targets)
        get_target_property(type ${target} TYPE)
        if(type STREQUAL "EXECUTABLE")
            add_custom_target(run-${target} ALL COMMAND ${target})
        endif()       
    endforeach()
endif()

# Deployment

if(TARGET pkgconfig-override-cxx)
    install(TARGETS pkgconfig-override-cxx)
else()
    install(CODE [[ # placeholder # ]])
endif()

endmacro()

cmake_language(DEFER CALL deferred_tests)
