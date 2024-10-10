message(STATUS "Loading Dependencies URLs ...")

include(external/helper_functions.cmake)

file(STRINGS deps.txt ONNXRUNTIME_DEPS_LIST)
foreach(ONNXRUNTIME_DEP IN LISTS ONNXRUNTIME_DEPS_LIST)
  # Lines start with "#" are comments
  if(NOT ONNXRUNTIME_DEP MATCHES "^#")
    # The first column is name
    list(POP_FRONT ONNXRUNTIME_DEP ONNXRUNTIME_DEP_NAME)
    # The second column is URL
    # The URL below may be a local file path or an HTTPS URL
    list(POP_FRONT ONNXRUNTIME_DEP ONNXRUNTIME_DEP_URL)
    set(DEP_URL_${ONNXRUNTIME_DEP_NAME} ${ONNXRUNTIME_DEP_URL})
    # The third column is SHA1 hash value
    set(DEP_SHA1_${ONNXRUNTIME_DEP_NAME} ${ONNXRUNTIME_DEP})

    if(ONNXRUNTIME_DEP_URL MATCHES "^https://")
      # Search a local mirror folder
      string(REGEX REPLACE "^https://" "${REPO_ROOT}/mirror/" LOCAL_URL "${ONNXRUNTIME_DEP_URL}")

      if(EXISTS "${LOCAL_URL}")
        cmake_path(ABSOLUTE_PATH LOCAL_URL)
        set(DEP_URL_${ONNXRUNTIME_DEP_NAME} "${LOCAL_URL}")
      endif()
    endif()
  endif()
endforeach()

message(STATUS "Loading Dependencies ...")
include(FetchContent)

# ABSL should be included before protobuf because protobuf may use absl
include(external/abseil-cpp.cmake)

set(RE2_BUILD_TESTING OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    re2
    URL ${DEP_URL_re2}
    URL_HASH SHA1=${DEP_SHA1_re2}
    FIND_PACKAGE_ARGS NAMES re2
)
onnxruntime_fetchcontent_makeavailable(re2)

if (onnxruntime_BUILD_UNIT_TESTS)
  # WebAssembly threading support in Node.js is still an experimental feature and
  # not working properly with googletest suite.
  if (CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set(gtest_disable_pthreads ON)
  endif()
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  if (IOS OR ANDROID)
    # on mobile platforms the absl flags class dumps the flag names (assumably for binary size), which breaks passing
    # any args to gtest executables, such as using --gtest_filter to debug a specific test.
    # Processing of compile definitions:
    # https://github.com/abseil/abseil-cpp/blob/8dc90ff07402cd027daec520bb77f46e51855889/absl/flags/config.h#L21
    # If set, this code throws away the flag and does nothing on registration, which results in no flags being known:
    # https://github.com/abseil/abseil-cpp/blob/8dc90ff07402cd027daec520bb77f46e51855889/absl/flags/flag.h#L205-L217
    set(GTEST_HAS_ABSL OFF CACHE BOOL "" FORCE)
  else()
    set(GTEST_HAS_ABSL ON CACHE BOOL "" FORCE)
  endif()
  # gtest and gmock
  FetchContent_Declare(
    googletest
    URL ${DEP_URL_googletest}
    URL_HASH SHA1=${DEP_SHA1_googletest}
    FIND_PACKAGE_ARGS 1.14.0...<2.0.0 NAMES GTest
  )
  FetchContent_MakeAvailable(googletest)
endif()

if (onnxruntime_BUILD_BENCHMARKS)
  # We will not need to test benchmark lib itself.
  set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "Disable benchmark testing as we don't need it.")
  # We will not need to install benchmark since we link it statically.
  set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "Disable benchmark install to avoid overwriting vendor install.")

  FetchContent_Declare(
    google_benchmark
    URL ${DEP_URL_google_benchmark}
    URL_HASH SHA1=${DEP_SHA1_google_benchmark}
    FIND_PACKAGE_ARGS NAMES benchmark
  )
  onnxruntime_fetchcontent_makeavailable(google_benchmark)
endif()

if (NOT WIN32)
  FetchContent_Declare(
    google_nsync
    URL ${DEP_URL_google_nsync}
    URL_HASH SHA1=${DEP_SHA1_google_nsync}
    FIND_PACKAGE_ARGS NAMES nsync unofficial-nsync
  )
  #nsync tests failed on Mac Build
  set(NSYNC_ENABLE_TESTS OFF CACHE BOOL "" FORCE)
  onnxruntime_fetchcontent_makeavailable(google_nsync)

  if (google_nsync_SOURCE_DIR)
    add_library(nsync::nsync_cpp ALIAS nsync_cpp)
    target_include_directories(nsync_cpp PUBLIC ${google_nsync_SOURCE_DIR}/public)
  endif()
  if(TARGET unofficial::nsync::nsync_cpp AND NOT TARGET nsync::nsync_cpp)
    message(STATUS "Aliasing unofficial::nsync::nsync_cpp to nsync::nsync_cpp")
    add_library(nsync::nsync_cpp ALIAS unofficial::nsync::nsync_cpp)
  endif()
endif()

if(onnxruntime_USE_MIMALLOC)
  FetchContent_Declare(
    mimalloc
    URL ${DEP_URL_mimalloc}
    URL_HASH SHA1=${DEP_SHA1_mimalloc}
    FIND_PACKAGE_ARGS NAMES mimalloc
  )
  FetchContent_MakeAvailable(mimalloc)
endif()

#Protobuf depends on utf8_range
FetchContent_Declare(
    utf8_range
    URL ${DEP_URL_utf8_range}
    URL_HASH SHA1=${DEP_SHA1_utf8_range}
    FIND_PACKAGE_ARGS NAMES utf8_range
)

set(utf8_range_ENABLE_TESTS OFF CACHE BOOL "Build test suite" FORCE)
set(utf8_range_ENABLE_INSTALL OFF CACHE BOOL "Configure installation" FORCE)

# The next line will generate an error message "fatal: not a git repository", but it is ok. It is from flatbuffers
onnxruntime_fetchcontent_makeavailable(utf8_range)
# protobuf's cmake/utf8_range.cmake has the following line
include_directories(${utf8_range_SOURCE_DIR})

# Download a protoc binary from Internet if needed
if(NOT ONNX_CUSTOM_PROTOC_EXECUTABLE)
  # This part of code is only for users' convenience. The code couldn't handle all cases. Users always can manually
  # download protoc from Protobuf's Github release page and pass the local path to the ONNX_CUSTOM_PROTOC_EXECUTABLE
  # variable.
  if (CMAKE_HOST_APPLE)
    # Using CMAKE_CROSSCOMPILING is not recommended for Apple target devices.
    # https://cmake.org/cmake/help/v3.26/variable/CMAKE_CROSSCOMPILING.html
    # To keep it simple, just download and use the universal protoc binary for all Apple host builds.
    FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_mac_universal} URL_HASH SHA1=${DEP_SHA1_protoc_mac_universal})
    FetchContent_Populate(protoc_binary)
    if(protoc_binary_SOURCE_DIR)
      message(STATUS "Use prebuilt protoc")
      set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_binary_SOURCE_DIR}/bin/protoc)
      set(PROTOC_EXECUTABLE ${ONNX_CUSTOM_PROTOC_EXECUTABLE})
    endif()
  elseif (CMAKE_CROSSCOMPILING)
    message(STATUS "CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
        FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_win64} URL_HASH SHA1=${DEP_SHA1_protoc_win64})
        FetchContent_Populate(protoc_binary)
      elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86")
        FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_win32} URL_HASH SHA1=${DEP_SHA1_protoc_win32})
        FetchContent_Populate(protoc_binary)
      endif()

      if(protoc_binary_SOURCE_DIR)
        message(STATUS "Use prebuilt protoc")
        set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_binary_SOURCE_DIR}/bin/protoc.exe)
        set(PROTOC_EXECUTABLE ${ONNX_CUSTOM_PROTOC_EXECUTABLE})
      endif()
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
        FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_linux_x64} URL_HASH SHA1=${DEP_SHA1_protoc_linux_x64})
        FetchContent_Populate(protoc_binary)
      elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i.86|x86?)$")
        FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_linux_x86} URL_HASH SHA1=${DEP_SHA1_protoc_linux_x86})
        FetchContent_Populate(protoc_binary)
      elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64.*")
        FetchContent_Declare(protoc_binary URL ${DEP_URL_protoc_linux_aarch64} URL_HASH SHA1=${DEP_SHA1_protoc_linux_aarch64})
        FetchContent_Populate(protoc_binary)
      endif()

      if(protoc_binary_SOURCE_DIR)
        message(STATUS "Use prebuilt protoc")
        set(ONNX_CUSTOM_PROTOC_EXECUTABLE ${protoc_binary_SOURCE_DIR}/bin/protoc)
        set(PROTOC_EXECUTABLE ${ONNX_CUSTOM_PROTOC_EXECUTABLE})
      endif()
    endif()

    if(NOT ONNX_CUSTOM_PROTOC_EXECUTABLE)
      message(FATAL_ERROR "ONNX_CUSTOM_PROTOC_EXECUTABLE must be set to cross-compile.")
    endif()
  endif()
endif()

# if ONNX_CUSTOM_PROTOC_EXECUTABLE is set we don't need to build the protoc binary
if (ONNX_CUSTOM_PROTOC_EXECUTABLE)
  if (NOT EXISTS "${ONNX_CUSTOM_PROTOC_EXECUTABLE}")
    message(FATAL_ERROR "ONNX_CUSTOM_PROTOC_EXECUTABLE is set to '${ONNX_CUSTOM_PROTOC_EXECUTABLE}' "
                        "but protoc executable was not found there.")
  endif()

  set(protobuf_BUILD_PROTOC_BINARIES OFF CACHE BOOL "Build protoc" FORCE)
endif()

#Here we support two build mode:
#1. if ONNX_CUSTOM_PROTOC_EXECUTABLE is set, build Protobuf from source, except protoc.exe. This mode is mainly
#   for cross-compiling
#2. if ONNX_CUSTOM_PROTOC_EXECUTABLE is not set, Compile everything(including protoc) from source code.
if(Patch_FOUND)
  set(ONNXRUNTIME_PROTOBUF_PATCH_COMMAND ${Patch_EXECUTABLE} --binary --ignore-whitespace -p1 < ${PROJECT_SOURCE_DIR}/patches/protobuf/protobuf_cmake.patch)
else()
 set(ONNXRUNTIME_PROTOBUF_PATCH_COMMAND "")
endif()

#Protobuf depends on absl and utf8_range
FetchContent_Declare(
  Protobuf
  URL ${DEP_URL_protobuf}
  URL_HASH SHA1=${DEP_SHA1_protobuf}
  PATCH_COMMAND ${ONNXRUNTIME_PROTOBUF_PATCH_COMMAND}
  FIND_PACKAGE_ARGS NAMES Protobuf protobuf
)

set(protobuf_BUILD_TESTS OFF CACHE BOOL "Build protobuf tests" FORCE)
#TODO: we'd better to turn the following option off. However, it will cause
# ".\build.bat --config Debug --parallel --skip_submodule_sync --update" fail with an error message:
# install(EXPORT "ONNXTargets" ...) includes target "onnx_proto" which requires target "libprotobuf-lite" that is
# not in any export set.
#set(protobuf_INSTALL OFF CACHE BOOL "Install protobuf binaries and files" FORCE)
set(protobuf_USE_EXTERNAL_GTEST ON CACHE BOOL "" FORCE)

if (ANDROID)
  set(protobuf_WITH_ZLIB OFF CACHE BOOL "Build protobuf with zlib support" FORCE)
endif()

if (onnxruntime_DISABLE_RTTI)
  set(protobuf_DISABLE_RTTI ON CACHE BOOL "Remove runtime type information in the binaries" FORCE)
endif()

include(protobuf_function)
#protobuf end

onnxruntime_fetchcontent_makeavailable(Protobuf)
if(Protobuf_FOUND)
  message(STATUS "Protobuf version: ${Protobuf_VERSION}")
else()
  # Adjust warning flags
  if (TARGET libprotoc)
    if (NOT MSVC)
      target_compile_options(libprotoc PRIVATE "-w")
    endif()
  endif()
  if (TARGET protoc)
    add_executable(protobuf::protoc ALIAS protoc)
    if (UNIX AND onnxruntime_ENABLE_LTO)
      #https://github.com/protocolbuffers/protobuf/issues/5923
      target_link_options(protoc PRIVATE "-Wl,--no-as-needed")
    endif()
    if (NOT MSVC)
      target_compile_options(protoc PRIVATE "-w")
    endif()
    get_target_property(PROTOC_OSX_ARCH protoc OSX_ARCHITECTURES)
    if (PROTOC_OSX_ARCH)
      if (${CMAKE_HOST_SYSTEM_PROCESSOR} IN_LIST PROTOC_OSX_ARCH)
        message(STATUS "protoc can run")
      else()
        list(APPEND PROTOC_OSX_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
        set_target_properties(protoc PROPERTIES OSX_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}")
        set_target_properties(libprotoc PROPERTIES OSX_ARCHITECTURES "${PROTOC_OSX_ARCH}")
        set_target_properties(libprotobuf PROPERTIES OSX_ARCHITECTURES "${PROTOC_OSX_ARCH}")
      endif()
    endif()
   endif()
  if (TARGET libprotobuf AND NOT MSVC)
    target_compile_options(libprotobuf PRIVATE "-w")
  endif()
  if (TARGET libprotobuf-lite AND NOT MSVC)
    target_compile_options(libprotobuf-lite PRIVATE "-w")
  endif()
endif()
if (onnxruntime_USE_FULL_PROTOBUF)
  set(PROTOBUF_LIB protobuf::libprotobuf)
else()
  set(PROTOBUF_LIB protobuf::libprotobuf-lite)
endif()

# date
set(ENABLE_DATE_TESTING  OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_TZ_DB  ON CACHE BOOL "" FORCE)

FetchContent_Declare(
  date
  URL ${DEP_URL_date}
  URL_HASH SHA1=${DEP_SHA1_date}
  FIND_PACKAGE_ARGS 3...<4 NAMES date
)
onnxruntime_fetchcontent_makeavailable(date)

FetchContent_Declare(
  mp11
  URL ${DEP_URL_mp11}
  URL_HASH SHA1=${DEP_SHA1_mp11}
  FIND_PACKAGE_ARGS NAMES Boost
)
onnxruntime_fetchcontent_makeavailable(mp11)
if(NOT TARGET Boost::mp11)
  if(onnxruntime_USE_VCPKG)
    find_package(Boost REQUIRED)
  endif()
  message(STATUS "Aliasing Boost::headers to Boost::mp11")
  add_library(Boost::mp11 ALIAS Boost::headers)
endif()

set(JSON_BuildTests OFF CACHE INTERNAL "")
set(JSON_Install OFF CACHE INTERNAL "")

FetchContent_Declare(
    nlohmann_json
    URL ${DEP_URL_json}
    URL_HASH SHA1=${DEP_SHA1_json}
    FIND_PACKAGE_ARGS 3.10 NAMES nlohmann_json
)
onnxruntime_fetchcontent_makeavailable(nlohmann_json)

#TODO: include clog first
if (onnxruntime_ENABLE_CPUINFO)
  # Adding pytorch CPU info library
  # TODO!! need a better way to find out the supported architectures
  list(LENGTH CMAKE_OSX_ARCHITECTURES CMAKE_OSX_ARCHITECTURES_LEN)
  if (APPLE)
    if (CMAKE_OSX_ARCHITECTURES_LEN LESS_EQUAL 1)
      set(CPUINFO_SUPPORTED TRUE)
    elseif (onnxruntime_BUILD_APPLE_FRAMEWORK)
      # We stitch multiple static libraries together when onnxruntime_BUILD_APPLE_FRAMEWORK is true,
      # but that would not work for universal static libraries
      message(FATAL_ERROR "universal binary is not supported for apple framework")
    endif()
  else()
    # if xnnpack is enabled in a wasm build it needs clog from cpuinfo, but we won't internally use cpuinfo
    # so we don't set CPUINFO_SUPPORTED in the CXX flags below.
    if (CMAKE_SYSTEM_NAME STREQUAL "Emscripten" AND NOT onnxruntime_USE_XNNPACK)
      set(CPUINFO_SUPPORTED FALSE)
    else()
      set(CPUINFO_SUPPORTED TRUE)
    endif()
    if (WIN32)
      set(CPUINFO_SUPPORTED TRUE)
    elseif (NOT ${onnxruntime_target_platform} MATCHES "^(i[3-6]86|AMD64|x86(_64)?|armv[5-8].*|aarch64|arm64)$")
      message(WARNING
        "Target processor architecture \"${onnxruntime_target_platform}\" is not supported in cpuinfo. "
        "cpuinfo not included."
      )
      set(CPUINFO_SUPPORTED FALSE)
    endif()
  endif()
else()
  set(CPUINFO_SUPPORTED FALSE)
endif()

if (CPUINFO_SUPPORTED)
  if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(IOS ON CACHE INTERNAL "")
    set(IOS_ARCH "${CMAKE_OSX_ARCHITECTURES}" CACHE INTERNAL "")
  endif()

  # if this is a wasm build with xnnpack (only type of wasm build where cpuinfo is involved)
  # we do not use cpuinfo in ORT code, so don't define CPUINFO_SUPPORTED.
  if (NOT CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    string(APPEND CMAKE_CXX_FLAGS " -DCPUINFO_SUPPORTED")
  endif()


  set(CPUINFO_BUILD_TOOLS OFF CACHE INTERNAL "")
  set(CPUINFO_BUILD_UNIT_TESTS OFF CACHE INTERNAL "")
  set(CPUINFO_BUILD_MOCK_TESTS OFF CACHE INTERNAL "")
  set(CPUINFO_BUILD_BENCHMARKS OFF CACHE INTERNAL "")
  if(onnxruntime_target_platform STREQUAL "ARM64EC")
      message(STATUS "Applying a patch for Windows ARM64EC in cpuinfo")
      FetchContent_Declare(
        pytorch_cpuinfo
        URL ${DEP_URL_pytorch_cpuinfo}
        URL_HASH SHA1=${DEP_SHA1_pytorch_cpuinfo}
        PATCH_COMMAND ${Patch_EXECUTABLE} -p1 < ${PROJECT_SOURCE_DIR}/patches/cpuinfo/9bb12d342fd9479679d505d93a478a6f9cd50a47.patch
        FIND_PACKAGE_ARGS NAMES cpuinfo
      )
  else()
      FetchContent_Declare(
        pytorch_cpuinfo
        URL ${DEP_URL_pytorch_cpuinfo}
        URL_HASH SHA1=${DEP_SHA1_pytorch_cpuinfo}
        FIND_PACKAGE_ARGS NAMES cpuinfo
      )
  endif()
  set(ONNXRUNTIME_CPUINFO_PROJ pytorch_cpuinfo)
  onnxruntime_fetchcontent_makeavailable(${ONNXRUNTIME_CPUINFO_PROJ})
  if(TARGET cpuinfo::cpuinfo AND NOT TARGET cpuinfo)
    message(STATUS "Aliasing cpuinfo::cpuinfo to cpuinfo")
    add_library(cpuinfo ALIAS cpuinfo::cpuinfo)
  endif()
endif()

# xnnpack depends on clog
# Android build should use the system's log library instead of clog
if ((CPUINFO_SUPPORTED OR onnxruntime_USE_XNNPACK) AND NOT ANDROID)
  set(CLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  FetchContent_Declare(
    pytorch_clog
    URL ${DEP_URL_pytorch_cpuinfo}
    URL_HASH SHA1=${DEP_SHA1_pytorch_cpuinfo}
    SOURCE_SUBDIR deps/clog
    FIND_PACKAGE_ARGS NAMES cpuinfo
  )
  set(ONNXRUNTIME_CLOG_PROJ pytorch_clog)
  onnxruntime_fetchcontent_makeavailable(${ONNXRUNTIME_CLOG_PROJ})
  set(ONNXRUNTIME_CLOG_TARGET_NAME clog)
  # if cpuinfo is from find_package, use it with imported name
  if(TARGET cpuinfo::clog)
    set(ONNXRUNTIME_CLOG_TARGET_NAME cpuinfo::clog)
  elseif(onnxruntime_USE_VCPKG)
    # however, later cpuinfo versions may not contain clog. use cpuinfo
    set(ONNXRUNTIME_CLOG_TARGET_NAME cpuinfo::cpuinfo)
  endif()
endif()

if(onnxruntime_USE_CUDA)
  FetchContent_Declare(
    GSL
    URL ${DEP_URL_microsoft_gsl}
    URL_HASH SHA1=${DEP_SHA1_microsoft_gsl}
    PATCH_COMMAND ${Patch_EXECUTABLE} --binary --ignore-whitespace -p1 < ${PROJECT_SOURCE_DIR}/patches/gsl/1064.patch
    FIND_PACKAGE_ARGS 4.0 NAMES Microsoft.GSL
  )
else()
  FetchContent_Declare(
    GSL
    URL ${DEP_URL_microsoft_gsl}
    URL_HASH SHA1=${DEP_SHA1_microsoft_gsl}
    FIND_PACKAGE_ARGS 4.0 NAMES Microsoft.GSL
  )
endif()
set(GSL_TARGET "Microsoft.GSL::GSL")
set(GSL_INCLUDE_DIR "$<TARGET_PROPERTY:${GSL_TARGET},INTERFACE_INCLUDE_DIRECTORIES>")
onnxruntime_fetchcontent_makeavailable(GSL)

find_path(safeint_SOURCE_DIR NAMES "SafeInt.hpp")
if(NOT safeint_SOURCE_DIR)
  unset(safeint_SOURCE_DIR)
  FetchContent_Declare(
      safeint
      URL ${DEP_URL_safeint}
      URL_HASH SHA1=${DEP_SHA1_safeint}
  )

  # use fetch content rather than makeavailable because safeint only includes unconditional test targets
  FetchContent_Populate(safeint)
endif()
add_library(safeint_interface INTERFACE)
target_include_directories(safeint_interface INTERFACE ${safeint_SOURCE_DIR})


# Flatbuffers
# We do not need to build flatc for iOS or Android Cross Compile
if (CMAKE_SYSTEM_NAME STREQUAL "iOS" OR CMAKE_SYSTEM_NAME STREQUAL "Android" OR CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
  set(FLATBUFFERS_BUILD_FLATC OFF CACHE BOOL "FLATBUFFERS_BUILD_FLATC" FORCE)
endif()
set(FLATBUFFERS_BUILD_TESTS OFF CACHE BOOL "FLATBUFFERS_BUILD_TESTS" FORCE)
set(FLATBUFFERS_INSTALL OFF CACHE BOOL "FLATBUFFERS_INSTALL" FORCE)
set(FLATBUFFERS_BUILD_FLATHASH OFF CACHE BOOL "FLATBUFFERS_BUILD_FLATHASH" FORCE)
set(FLATBUFFERS_BUILD_FLATLIB ON CACHE BOOL "FLATBUFFERS_BUILD_FLATLIB" FORCE)
if(Patch_FOUND)
  set(ONNXRUNTIME_FLATBUFFERS_PATCH_COMMAND ${Patch_EXECUTABLE} --binary --ignore-whitespace -p1 < ${PROJECT_SOURCE_DIR}/patches/flatbuffers/flatbuffers.patch)
else()
 set(ONNXRUNTIME_FLATBUFFERS_PATCH_COMMAND "")
endif()

#flatbuffers 1.11.0 does not have flatbuffers::IsOutRange, therefore we require 1.12.0+
FetchContent_Declare(
    flatbuffers
    URL ${DEP_URL_flatbuffers}
    URL_HASH SHA1=${DEP_SHA1_flatbuffers}
    PATCH_COMMAND ${ONNXRUNTIME_FLATBUFFERS_PATCH_COMMAND}
    FIND_PACKAGE_ARGS 23.5.9 NAMES Flatbuffers flatbuffers
)

onnxruntime_fetchcontent_makeavailable(flatbuffers)
if(NOT flatbuffers_FOUND)
  if(NOT TARGET flatbuffers::flatbuffers)
    add_library(flatbuffers::flatbuffers ALIAS flatbuffers)
  endif()
  if(TARGET flatc AND NOT TARGET flatbuffers::flatc)
    add_executable(flatbuffers::flatc ALIAS flatc)
  endif()
  if (GDK_PLATFORM)
    # cstdlib only defines std::getenv when _CRT_USE_WINAPI_FAMILY_DESKTOP_APP is defined, which
    # is probably an oversight for GDK/Xbox builds (::getenv exists and works).
    file(WRITE ${CMAKE_BINARY_DIR}/gdk_cstdlib_wrapper.h [[
#pragma once
#ifdef __cplusplus
#include <cstdlib>
namespace std { using ::getenv; }
#endif
]])
    if(TARGET flatbuffers)
      target_compile_options(flatbuffers PRIVATE /FI${CMAKE_BINARY_DIR}/gdk_cstdlib_wrapper.h)
    endif()
    if(TARGET flatc)
      target_compile_options(flatc PRIVATE /FI${CMAKE_BINARY_DIR}/gdk_cstdlib_wrapper.h)
    endif()
  endif()
endif()

# ONNX
if (NOT onnxruntime_USE_FULL_PROTOBUF)
  set(ONNX_USE_LITE_PROTO ON CACHE BOOL "" FORCE)
else()
  set(ONNX_USE_LITE_PROTO OFF CACHE BOOL "" FORCE)
endif()

if(Patch_FOUND)
  set(ONNXRUNTIME_ONNX_PATCH_COMMAND ${Patch_EXECUTABLE} --binary --ignore-whitespace -p1 < ${PROJECT_SOURCE_DIR}/patches/onnx/onnx.patch)
else()
  set(ONNXRUNTIME_ONNX_PATCH_COMMAND "")
endif()

FetchContent_Declare(
  onnx
  URL ${DEP_URL_onnx}
  URL_HASH SHA1=${DEP_SHA1_onnx}
  PATCH_COMMAND ${ONNXRUNTIME_ONNX_PATCH_COMMAND}
  FIND_PACKAGE_ARGS NAMES ONNX onnx
)
if (NOT onnxruntime_MINIMAL_BUILD)
  onnxruntime_fetchcontent_makeavailable(onnx)
else()
  include(onnx_minimal)
endif()

if(TARGET ONNX::onnx AND NOT TARGET onnx)
  message(STATUS "Aliasing ONNX::onnx to onnx")
  add_library(onnx ALIAS ONNX::onnx)
endif()
if(TARGET ONNX::onnx_proto AND NOT TARGET onnx_proto)
  message(STATUS "Aliasing ONNX::onnx_proto to onnx_proto")
  add_library(onnx_proto ALIAS ONNX::onnx_proto)
endif()

find_package(Eigen3 CONFIG)
if(Eigen3_FOUND)
  get_target_property(eigen_INCLUDE_DIRS Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
else()
  include(eigen) # FetchContent
endif()

if(onnxruntime_USE_VCPKG)
  find_package(wil CONFIG REQUIRED)
  set(WIL_TARGET "WIL::WIL")
else()
  include(wil) # FetchContent
endif()

# XNNPACK EP
if (onnxruntime_USE_XNNPACK)
  if (onnxruntime_DISABLE_CONTRIB_OPS)
    message(FATAL_ERROR "XNNPACK EP requires the internal NHWC contrib ops to be available "
                         "but onnxruntime_DISABLE_CONTRIB_OPS is ON")
  endif()
  include(xnnpack)
endif()

if (onnxruntime_USE_MIMALLOC)
  add_definitions(-DUSE_MIMALLOC)

  set(MI_OVERRIDE OFF CACHE BOOL "" FORCE)
  set(MI_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  set(MI_DEBUG_FULL OFF CACHE BOOL "" FORCE)
  set(MI_BUILD_SHARED OFF CACHE BOOL "" FORCE)
  onnxruntime_fetchcontent_makeavailable(mimalloc)
endif()

#onnxruntime_EXTERNAL_LIBRARIES could contain onnx, onnx_proto,libprotobuf, cuda/cudnn,
# dnnl/mklml, onnxruntime_codegen_tvm, tvm and pthread
# pthread is always at the last
set(onnxruntime_EXTERNAL_LIBRARIES ${onnxruntime_EXTERNAL_LIBRARIES_XNNPACK} ${WIL_TARGET} nlohmann_json::nlohmann_json onnx onnx_proto ${PROTOBUF_LIB} re2::re2 Boost::mp11 safeint_interface flatbuffers::flatbuffers ${GSL_TARGET} ${ABSEIL_LIBS} date::date ${ONNXRUNTIME_CLOG_TARGET_NAME})
# The source code of onnx_proto is generated, we must build this lib first before starting to compile the other source code that uses ONNX protobuf types.
# The other libs do not have the problem. All the sources are already there. We can compile them in any order.
set(onnxruntime_EXTERNAL_DEPENDENCIES onnx_proto flatbuffers::flatbuffers)

if(NOT (onnx_FOUND OR ONNX_FOUND)) # building ONNX from source
  target_compile_definitions(onnx PUBLIC $<TARGET_PROPERTY:onnx_proto,INTERFACE_COMPILE_DEFINITIONS> PRIVATE "__ONNX_DISABLE_STATIC_REGISTRATION")
  if (NOT onnxruntime_USE_FULL_PROTOBUF)
    target_compile_definitions(onnx PUBLIC "__ONNX_NO_DOC_STRINGS")
  endif()
endif()

if (onnxruntime_RUN_ONNX_TESTS)
  add_definitions(-DORT_RUN_EXTERNAL_ONNX_TESTS)
endif()


if(onnxruntime_ENABLE_ATEN)
  message(STATUS "Aten fallback is enabled.")
  FetchContent_Declare(
    dlpack
    URL ${DEP_URL_dlpack}
    URL_HASH SHA1=${DEP_SHA1_dlpack}
    FIND_PACKAGE_ARGS NAMES dlpack
  )
  # We can't use onnxruntime_fetchcontent_makeavailable since some part of the the dlpack code is Linux only.
  # For example, dlpackcpp.h uses posix_memalign.
  FetchContent_Populate(dlpack)
endif()

if(onnxruntime_ENABLE_TRAINING OR (onnxruntime_ENABLE_TRAINING_APIS AND onnxruntime_BUILD_UNIT_TESTS))
  # Once code under orttraining/orttraining/models dir is removed "onnxruntime_ENABLE_TRAINING" should be removed from
  # this conditional
  FetchContent_Declare(
    cxxopts
    URL ${DEP_URL_cxxopts}
    URL_HASH SHA1=${DEP_SHA1_cxxopts}
    FIND_PACKAGE_ARGS NAMES cxxopts
  )
  set(CXXOPTS_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
  set(CXXOPTS_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  onnxruntime_fetchcontent_makeavailable(cxxopts)
endif()

if (onnxruntime_USE_COREML)
  FetchContent_Declare(
    coremltools
    URL ${DEP_URL_coremltools}
    URL_HASH SHA1=${DEP_SHA1_coremltools}
    PATCH_COMMAND ${Patch_EXECUTABLE} --binary --ignore-whitespace -p1 < ${PROJECT_SOURCE_DIR}/patches/coremltools/crossplatformbuild.patch
  )
  # we don't build directly so use Populate. selected files are built from onnxruntime_providers_coreml.cmake
  FetchContent_Populate(coremltools)
endif()

message(STATUS "Finished fetching external dependencies")

set(onnxruntime_LINK_DIRS )

if (onnxruntime_USE_CUDA)
      find_package(CUDAToolkit REQUIRED)

      if(onnxruntime_CUDNN_HOME)
        file(TO_CMAKE_PATH ${onnxruntime_CUDNN_HOME} onnxruntime_CUDNN_HOME)
        set(CUDNN_PATH ${onnxruntime_CUDNN_HOME})
      endif()
endif()

if(onnxruntime_USE_SNPE)
    include(external/find_snpe.cmake)
    list(APPEND onnxruntime_EXTERNAL_LIBRARIES ${SNPE_NN_LIBS})
endif()

FILE(TO_NATIVE_PATH ${CMAKE_BINARY_DIR}  ORT_BINARY_DIR)
FILE(TO_NATIVE_PATH ${PROJECT_SOURCE_DIR}  ORT_SOURCE_DIR)
