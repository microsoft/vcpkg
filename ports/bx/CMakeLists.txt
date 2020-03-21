
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
project(bx VERSION 2020.03.14.0 LANGUAGES C CXX)

include(GNUInstallDirs)

if (MSVC OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC"))
    set(BX_COMPAT MSVC)
elseif (MINGW)
    set(BX_COMPAT MINGW)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(BX_COMPAT OSX)
endif()

# dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads)

# bx compat target
add_library(compat INTERFACE)
add_library(Bx::compat ALIAS compat)

target_include_directories(compat INTERFACE
    $<BUILD_INTERFACE:$<$<STREQUAL:${BX_COMPAT},MSVC>:${CMAKE_CURRENT_SOURCE_DIR}/include/compat/msvc>>
    $<BUILD_INTERFACE:$<$<STREQUAL:${BX_COMPAT},MINGW>:${CMAKE_CURRENT_SOURCE_DIR}/include/compat/mingw>>
    $<BUILD_INTERFACE:$<$<STREQUAL:${BX_COMPAT},OSX>:${CMAKE_CURRENT_SOURCE_DIR}/include/compat/osx>>
)
if (BX_COMPAT) # using generator expressions would break import prefix replacement
    target_include_directories(compat INTERFACE  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/bx/compat>)
endif()

target_compile_definitions(compat INTERFACE
    "__STDC_LIMIT_MACROS"
    "__STDC_FORMAT_MACROS"
    "__STDC_CONSTANT_MACROS"
)


# bx library target
add_library(bx)
add_library(Bx::bx ALIAS bx)
target_compile_features(bx PUBLIC cxx_std_14)

target_sources(bx
    PRIVATE
        "src/amalgamated.cpp"
)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_sources(bx
        PUBLIC
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_DATADIR}/bx/bx.natvis>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_DATADIR}/bx/tinystl.natvis>
    )
endif()

target_include_directories(bx
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>

        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty>
)

target_compile_definitions(bx
    PRIVATE
        "BX_CONFIG_DEBUG=$<BOOL:${BX_CONFIG_DEBUG}>"
)

target_link_libraries(bx
    PUBLIC
        Threads::Threads
        ${CMAKE_DL_LIBS}

    PRIVATE
        Bx::compat
)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(bx
        PUBLIC
            psapi
    )
endif()

# bin2c tool
add_executable(bin2c)
add_executable(Bx::bin2c ALIAS bin2c)
target_sources(bin2c PRIVATE
    tools/bin2c/bin2c.cpp
)

target_link_libraries(bin2c PRIVATE Bx::bx)

# lemon tool
add_executable(lemon)
add_executable(Bx::lemon ALIAS lemon)
target_sources(lemon PRIVATE
    tools/lemon/lemon.c
)

# test project
if (BUILD_TESTING)
    enable_testing()
    add_executable(bx.test)

    file(GLOB BX_TEST_SOURCES tests/*_test.cpp)
    target_sources(bx.test PRIVATE ${BX_TEST_SOURCES})

    target_link_libraries(bx.test PRIVATE Bx::bx Bx::compat)

    add_test(NAME bx.test COMMAND bx.test)
endif()

# installation logic
if (BX_INSTALL_TOOLING)
    install(TARGETS bin2c lemon EXPORT tool-targets)
    install(FILES tools/lemon/lempar.c DESTINATION "${CMAKE_INSTALL_BINDIR}")

    install(EXPORT tool-targets NAMESPACE Bx:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bx/")
endif()

install(TARGETS bx compat EXPORT bx-targets)
if (NOT BX_DISABLE_HEADER_INSTALL)
    install(DIRECTORY include/bx/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/bx/")
    if (BX_COMPAT STREQUAL "MSVC")
        install(DIRECTORY include/compat/msvc/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/bx/compat")
    elseif (BX_COMPAT STREQUAL "MINGW")
        install(DIRECTORY include/compat/mingw/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/bx/compat")
    elseif (BX_COMPAT STREQUAL "OSX")
        install(DIRECTORY include/compat/osx/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/bx/compat")
    endif()
    install(DIRECTORY include/tinystl/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/tinystl/")
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
        install(FILES
            scripts/bx.natvis
            scripts/tinystl.natvis

            DESTINATION "${CMAKE_INSTALL_DATADIR}/bx/"
        )
    endif()
endif()
install(EXPORT bx-targets NAMESPACE Bx:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bx/")
