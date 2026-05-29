cmake_minimum_required(VERSION 3.14)

project(wepoll C)

add_library(wepoll wepoll.c)

if (MSVC)
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(
            wepoll
            PRIVATE
                "-DWEPOLL_EXPORT=__declspec(dllexport)"
        )
    endif ()

    target_compile_options(wepoll PRIVATE /Wall /wd4127 /wd4201 /wd4242 /wd4710 /wd4711 /wd4820)

    if (MSVC_VERSION GREATER_EQUAL 1900)
        target_compile_options(wepoll PRIVATE /wd5045)
    endif ()
else ()
    target_compile_definitions(
        wepoll
        PRIVATE
            "-DWEPOLL_EXPORT=__attribute__((visibility(\"default\")))"
    )

    target_compile_options(wepoll PRIVATE -Wall -Wextra -Werror -fvisibility=hidden)
endif ()

target_link_libraries(wepoll PUBLIC ws2_32)

set_target_properties(
    wepoll
    PROPERTIES
        OUTPUT_NAME wepoll
        PUBLIC_HEADER wepoll.h
)

install(TARGETS wepoll)
