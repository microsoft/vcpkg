cmake_minimum_required(VERSION 3.9)

file(STRINGS ${CMAKE_CURRENT_LIST_DIR}/configure.ac config_ac_contents)

foreach (line ${config_ac_contents})
    if (line MATCHES "AC_INIT\\(\\[libsodium\\],\\[([0-9.]+)\\],")
        set(VERSION ${CMAKE_MATCH_1})
    elseif (line MATCHES "SODIUM_LIBRARY_VERSION_(MAJOR|MINOR)=([0-9]+)")
        set(SODIUM_LIBRARY_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
    endif ()
endforeach ()

message("VERSION: ${VERSION}")
message("SODIUM_LIBRARY_VERSION_MAJOR: ${SODIUM_LIBRARY_VERSION_MAJOR}")
message("SODIUM_LIBRARY_VERSION_MINOR: ${SODIUM_LIBRARY_VERSION_MINOR}")

project(libsodium VERSION ${VERSION} LANGUAGES C)

include(GNUInstallDirs)
include(TestBigEndian)

set(CMAKE_C_STANDARD 99)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

option(BUILD_SHARED_LIBS "Build shared library" ${BUILD_SHARED_LIBS})

configure_file(
    src/libsodium/include/sodium/version.h.in
    ${CMAKE_CURRENT_LIST_DIR}/src/libsodium/include/sodium/version.h
)

file(GLOB sodium_headers ${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium/*.h)
list(APPEND sodium_headers ${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium.h)

file(GLOB_RECURSE sodium_sources ${PROJECT_SOURCE_DIR}/src/libsodium/*.c)

if (MSVC)
    enable_language(RC)

    list(APPEND sodium_sources
        builds/msvc/resource.rc
    )
endif ()

add_library(${PROJECT_NAME}
    ${sodium_headers}
    ${sodium_sources}
)

if (MSVC)
    target_compile_options(${PROJECT_NAME}
        PRIVATE
            /D_CONSOLE
            /D_CRT_SECURE_NO_WARNINGS
            /DNATIVE_LITTLE_ENDIAN=1
            /DCPU_UNALIGNED_ACCESS=1
            /MP
            /Dinline=__inline
            /wd4068 # Unknown pragma
            /wd4197
            /wd4244 # Macro redefinition
    )

    target_link_libraries(${PROJECT_NAME}
        PUBLIC
            advapi32
    )
endif ()

if (BUILD_SHARED_LIBS)
    target_compile_definitions(${PROJECT_NAME}
        PRIVATE
            SODIUM_DLL_EXPORT
    )
else ()
    target_compile_definitions(${PROJECT_NAME}
        PUBLIC
            SODIUM_STATIC
    )
endif ()

target_include_directories(${PROJECT_NAME}
    PRIVATE
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/libsodium/include/sodium>
    INTERFACE
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(DIRECTORY src/libsodium/include/
    DESTINATION include/
    USE_SOURCE_PERMISSIONS
    FILES_MATCHING PATTERN "*.h"
)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-config
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(EXPORT ${PROJECT_NAME}-config
    FILE unofficial-${PROJECT_NAME}-config.cmake
    NAMESPACE unofficial-${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-${PROJECT_NAME}
)

# References:
# https://github.com/boost-cmake/bcm/wiki/Cmake-best-practices-and-guidelines
# https://github.com/jedisct1/libsodium/pull/74/files
# https://github.com/jedisct1/libsodium/pull/156/files
# https://github.com/jedisct1/libsodium/pull/181/files
# https://github.com/jedisct1/libsodium/issues/378
# https://github.com/jedisct1/libsodium/issues/636
# https://github.com/jedisct1/libsodium/issues/771
# https://github.com/jedisct1/libsodium/blob/gyp/sodium.gyp
# https://github.com/imefisto/cmake-libsodium
# https://github.com/Cyberunner23/libsodium-CMake
