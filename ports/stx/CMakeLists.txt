# MIT License
#
# Copyright (c) 2020 Basit Ayantunde
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

cmake_minimum_required(VERSION 3.13)

project(
  Stx
  VERSION 1.0.1
  DESCRIPTION "A set of utility extensions to the C++ Standard Library"
  HOMEPAGE_URL "https://github.com/lamarrr/STX"
  LANGUAGES CXX)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)

include(CMakeDependentOption)
include(HandleFlags)
include(CheckCXXSourceCompiles)

# we have to inform the user of the standards version change, else it'll cause
# possible compatibility issues
if(NOT CMAKE_CXX_STANDARD OR CMAKE_CXX_STANDARD LESS 17)
  if(CMAKE_CXX_STANDARD)
    message(
      WARNING
        "[STX] STX requires at least C++ 17 but 'CMAKE_CXX_STANDARD' was set to ${CMAKE_CXX_STANDARD} (C++ ${CMAKE_CXX_STANDARD}), 'CMAKE_CXX_STANDARD' will be set to 17 (C++ 17). Set 'CMAKE_CXX_STANDARD' to 17 (C++ 17) or later standards to silence this warning"
    )
  else()
    message(
      WARNING
        "[STX] STX requires at least C++ 17 but 'CMAKE_CXX_STANDARD' was not set. 'CMAKE_CXX_STANDARD' will be set to 17 (C++ 17). Set 'CMAKE_CXX_STANDARD' to 17 (C++ 17) or later standards to silence this warning"
    )
  endif()

  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

# ===============================================
#
# === Configuration Options
#
# ===============================================

option(STX_BUILD_SHARED "Build STX as a shared library" OFF)

option(STX_BUILD_TESTS "Build tests" OFF)

option(STX_ENABLE_DEBUG_ASSERTIONS "Enable debug mode assertions"
       ${STX_BUILD_TESTS})

option(STX_BUILD_DOCS "Build documentation" OFF)

option(STX_BUILD_BENCHMARKS "Build benchmarks" OFF)

cmake_dependent_option(STX_SANITIZE_TESTS "Build sanitized tests" OFF
                       "STX_BUILD_TESTS" OFF)

# this feature replaces the default panic handler, by default it is set to print
# the panic report and abort the program. The handler is thread-safe.
option(
  STX_OVERRIDE_PANIC_HANDLER
  "Override the default panic behaviour (You can read the docs for more details)"
  OFF)

# the default panic hook calls the provided panic handler. the behaviour can be
# changed at runtime especially when built as a shared library. Making panic
# hooks visible enables you to control the panic behaviour of the dynamically
# loaded library that depends on STX, i.e. for device drivers you might not want
# them to cause the whole program to fail on a panic.
option(STX_VISIBLE_PANIC_HOOK "Make runtime panic hook visible"
       ${STX_BUILD_SHARED})

# enables the backtrace library, we won't allow it to work by default when built
# as a shared library for now until we find a reason to, If you find it
# inconvenient please drop a PR!.
option(STX_ENABLE_BACKTRACE "Enables the backtrace feature" OFF)

# disables printing backtraces on panic by the default panic handler. This
# requires that panic backtraces are enabled and that the panic handler is not
# overriden.
cmake_dependent_option(
  STX_ENABLE_PANIC_BACKTRACE "Enables the panic backtrace feature" ON
  "STX_ENABLE_BACKTRACE;NOT STX_OVERRIDE_PANIC_HANDLER" OFF)

# ===============================================
#
# === Configuration Options Logging
#
# ===============================================

message(STATUS "[STX] Build as a shared library: " ${STX_BUILD_SHARED})
message(STATUS "[STX] Build tests: " ${STX_BUILD_TESTS})
message(STATUS "[STX] Enable debug mode assertions: "
               ${STX_ENABLE_DEBUG_ASSERTIONS})
message(STATUS "[STX] Build documentation: " ${STX_BUILD_DOCS})
message(STATUS "[STX] Build benchmarks: " ${STX_BUILD_BENCHMARKS})
message(STATUS "[STX] Build sanitized tests: " ${STX_SANITIZE_TESTS})
message(STATUS "[STX] Override panic handler: " ${STX_OVERRIDE_PANIC_HANDLER})
message(STATUS "[STX] Make runtime panic hook visible: "
               ${STX_VISIBLE_PANIC_HOOK})
message(STATUS "[STX] Enable backtrace: " ${STX_ENABLE_BACKTRACE})
message(STATUS "[STX] Enable panic backtrace: " ${STX_ENABLE_PANIC_BACKTRACE})

# ===============================================
#
# === Flags and Global Definitions
#
# ===============================================

list(APPEND STX_COMPILER_DEFS)
list(APPEND STX_FLAGS)
list(APPEND STX_WARNING_FLAGS)

# tests make use of macros which don't use the result, especially
# EXPECT_ANY_THROW, the result is thus discarded and [[nodiscard]] will raise
# warnings
list(APPEND STX_TEST_WARNING_FLAGS)

# ===============================================
#
# === Configure Flags
#
# ===============================================

if(MSVC)
  append_flags_if_supported(STX_WARNING_FLAGS "/W4")
else()
  append_flags_if_supported(STX_WARNING_FLAGS "-Wpedantic" "-Wall" "-Wextra")
endif()

# if available, add MSVC equivalent
append_flags_if_supported(STX_TEST_WARNING_FLAGS "-Wno-unused-result"
                          "-Wno-unused-variable")

# ===============================================
#
# === Configuration Definitions and Platform Support
#
# ===============================================

if(STX_ENABLE_DEBUG_ASSERTIONS)
  list(APPEND STX_COMPILER_DEFS "STX_ENABLE_DEBUG_ASSERTIONS")
endif()

if(STX_OVERRIDE_PANIC_HANDLER)
  list(APPEND STX_COMPILER_DEFS "STX_OVERRIDE_PANIC_HANDLER")
endif()

if(STX_VISIBLE_PANIC_HOOK)
  list(APPEND STX_COMPILER_DEFS "STX_VISIBLE_PANIC_HOOK")
endif()

if(STX_ENABLE_PANIC_BACKTRACE)
  list(APPEND STX_COMPILER_DEFS "STX_ENABLE_PANIC_BACKTRACE")
endif()

if(STX_ENABLE_BACKTRACE)
  # TODO(lamarrr): check platform support
endif()

# some microcontroller platforms 'arm-gcc-none especially" may not have
# std::thread enabled if so, we remove the thread facilities, this will cause
# compilation errors otherwise, since the classes won't be available
check_cxx_source_compiles(
  "
#include <thread>
#include <mutex>

int main(){
  std::this_thread::get_id();
  std::mutex mutex;
}
"
  LIBSTX_HAS_STD_THREAD_MUTEX)

if(NOT LIBSTX_HAS_STD_THREAD_MUTEX)
  list(APPEND STX_COMPILER_DEFS "STX_NO_STD_THREAD_MUTEX")
endif()

# ===============================================
#
# === Dependencies
#
# ===============================================

if(STX_ENABLE_BACKTRACE)
  find_package(absl CONFIG REQUIRED)
endif()

# the atomics library doesn't automatically link on my Android phone
if(ANDROID)
  message(STATUS "[STX] Checking for Android's libatomic")
  find_library(LibAtomic atomic)

  if(NOT LibAtomic)
    message(WARNING "[STX] Android's libatomic was not found")
  endif()
endif()

# ===============================================
#
# === Source Files
#
# ===============================================

if(STX_ENABLE_BACKTRACE)
  list(APPEND STX_SRCS src/backtrace.cc)
endif()

list(APPEND STX_SRCS src/panic/hook.cc src/panic.cc)

# ===============================================
#
# === Library Setup
#
# ===============================================

if(STX_BUILD_SHARED)
  add_library(stx SHARED ${STX_SRCS})
else()
  add_library(stx STATIC ${STX_SRCS})
endif()

target_include_directories(stx PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

target_compile_options(stx PRIVATE ${STX_FLAGS} ${STX_WARNING_FLAGS})
target_compile_definitions(stx PUBLIC ${STX_COMPILER_DEFS})
target_link_libraries(stx ${STX_LIB_DEPENDENCIES})

if(STX_ENABLE_BACKTRACE)
  target_link_libraries(stx PUBLIC absl::stacktrace absl::symbolize)
endif()

if(ANDROID)
  target_link_libraries(stx ${LibAtomic})
endif()

# ===============================================
#
# === Test Dependencies
#
# ===============================================

if(STX_BUILD_TESTS)

  if(NOT EXISTS third_party/googletest)
    execute_process(
      COMMAND git submodule update --init --recursive third_party/googletest
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  endif()

  set(BUILD_GMOCK
      OFF
      CACHE BOOL "Build GMOCK" FORCE)
  set(INSTALL_GTEST
      OFF
      CACHE BOOL "Install GTest" FORCE)
  add_subdirectory(third_party/googletest)
endif()

# ===============================================
#
# === Benchmark Dependencies
#
# ===============================================


if(STX_BUILD_BENCHMARKS)

  if(NOT EXISTS third_party/benchmark)
    execute_process(
      COMMAND git submodule update --init --recursive third_party/benchmark
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  endif()

  set(BENCHMARK_ENABLE_TESTING OFF)
  add_subdirectory(third_party/benchmark)
endif()

# ===============================================
#
# === Documentation Dependencies
#
# ===============================================

if(STX_BUILD_DOCS)
  find_package(Doxygen) # sub-packages?
  if(NOT Doxygen_FOUND)
    message(
      WARNING "Doxygen can not be found, Documentation will not be built.")
    set(STX_BUILD_DOCS
        OFF
        CACHE BOOL "Build documentation" FORCE)
  endif()
endif()

# ===============================================
#
# === Tests Setup
#
# ===============================================

list(
  APPEND STX_TEST_SRCS
         tests/common_test.cc
         tests/constexpr_test.cc
         tests/option_test.cc
         tests/panic_test.cc
         tests/report_test.cc
         tests/result_test.cc
         tests/tests.cc)

if(STX_ENABLE_BACKTRACE)
  list(APPEND STX_TEST_SRCS tests/backtrace_test.cc)
endif()

if(STX_BUILD_TESTS)

  add_executable(stx_tests ${STX_TEST_SRCS})
  target_link_libraries(stx_tests stx gtest_main gtest)
  target_include_directories(stx_tests PRIVATE tests)
  target_compile_options(stx_tests PRIVATE ${STX_FLAGS} ${STX_WARNING_FLAGS}
                                           ${STX_TEST_WARNING_FLAGS})
  target_compile_definitions(stx_tests PRIVATE STX_OVERRIDE_PANIC_HANDLER)
  add_custom_target(
    run_tests
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/stx_tests
    DEPENDS stx_tests)

  macro(try_add_sanitized_test sanitize_mode)
    # only known to be supported on GCC and Clang, If otherwise drop a PR!
    if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU|Clang")

      add_executable(stx_tests_${sanitize_mode}_sanitized ${STX_TEST_SRCS})
      target_compile_options(
        stx_tests_${sanitize_mode}_sanitized
        PRIVATE "-fsanitize=${sanitize_mode}" ${STX_FLAGS} ${STX_WARNING_FLAGS}
                ${STX_TEST_WARNING_FLAGS})
      target_compile_definitions(stx_tests_${sanitize_mode}_sanitized
                                 PRIVATE STX_OVERRIDE_PANIC_HANDLER)
      target_include_directories(stx_tests_${sanitize_mode}_sanitized
                                 PRIVATE tests)
      target_link_libraries(stx_tests_${sanitize_mode}_sanitized stx gtest_main
                            gtest "-fsanitize=${sanitize_mode}")

    else()

      message(
        WARNING
          "[STX] We only build sanitized tests for GCC and Clang. Sanitized tests will not be built"
      )

    endif()
  endmacro(try_add_sanitized_test sanitize_mode)

  if(STX_SANITIZE_TESTS)
    try_add_sanitized_test(undefined)
    try_add_sanitized_test(address)
    try_add_sanitized_test(leak)
    try_add_sanitized_test(thread)
  endif()

endif()

# ===============================================
#
# === Benchmark Setup
#
# ===============================================

if(STX_BUILD_BENCHMARKS)

  macro(add_benchmark benchmark_name file)
    add_executable(stx_benchmark_${benchmark_name} "benchmarks/${file}")
    target_link_libraries(stx_benchmark_${benchmark_name} stx benchmark
                          benchmark_main)
    target_compile_options(stx_benchmark_${benchmark_name}
                           PRIVATE ${STX_FLAGS} ${STX_WARNING_FLAGS})
  endmacro(add_benchmark benchmark_name)

  add_benchmark(one_op one_op.cc)
  add_benchmark(two_op two_op.cc)

endif()

# ===============================================
#
# === Documentation Setup
#
# ===============================================

if(STX_BUILD_DOCS)
  set(STX_DOXYGEN_IN ${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in)
  set(STX_DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/docs/Doxyfile)

  # request to configure the file
  configure_file(${STX_DOXYGEN_IN} ${STX_DOXYGEN_OUT} @ONLY)
  message(STATUS "Doxygen build started")

  # note the option ALL which allows to build the docs together with the
  # application
  add_custom_target(
    docs ALL
    COMMAND ${DOXYGEN_EXECUTABLE} ${STX_DOXYGEN_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    COMMENT "Generating API documentation with Doxygen"
    VERBATIM)

  file(COPY assets/fonts assets/images
       DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/docs/html/assets)

endif()

set(PUBLIC_HEADERS
  stx/backtrace.h
  stx/common.h
  stx/config.h
  stx/option.h
  stx/panic.h
  stx/report.h
  stx/result.h
  stx/source_location.h
  stx/internal/option_result.h
  stx/internal/panic_helpers.h
  stx/internal/try.h
  stx/panic/hook.h
  stx/panic/handlers/print.h
  stx/panic/handlers/abort/abort.h
  stx/panic/handlers/default/default.h
  stx/panic/handlers/halt/halt.h
)

install(
    TARGETS stx
    EXPORT stx
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Headers makes relative includes so directory structure must be kept
foreach(HEADER ${PUBLIC_HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(
        FILES include/${HEADER}
        DESTINATION include/${HEADER_DIR}
    )
endforeach()

install(
    EXPORT stx
    DESTINATION share/stx
    FILE stxConfig.cmake
    NAMESPACE stx::
)
