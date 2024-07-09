cmake_minimum_required(VERSION 3.8)
project(yara C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
else()
  find_library(HAVE_LIBM NAMES m)
endif()


find_package(OpenSSL REQUIRED)

include_directories(
  .
  libyara
  libyara/include
)

set(PROC_PLATFORM_SOURCE "libyara/proc/none.c")
set(PROC_PLATFORM_INTERFACE "USE_NO_PROC")

if(APPLE AND CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(PROC_PLATFORM_SOURCE "libyara/proc/mach.c")
  set(PROC_PLATFORM_INTERFACE "USE_MACH_PROC")
elseif(WIN32 OR MINGW OR CYGWIN)
  set(PROC_PLATFORM_SOURCE "libyara/proc/windows.c")
  set(PROC_PLATFORM_INTERFACE "USE_WINDOWS_PROC")
elseif(UNIX AND CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(THREADS_PREFER_PTHREAD_FLAG TRUE)
  set(PROC_PLATFORM_SOURCE "libyara/proc/linux.c")
  set(PROC_PLATFORM_INTERFACE "USE_LINUX_PROC")
endif()

set(
  libyara_sources
  libyara/ahocorasick.c
  libyara/arena.c
  libyara/atoms.c
  libyara/base64.c
  libyara/bitmask.c
  libyara/compiler.c
  libyara/endian.c
  libyara/exec.c
  libyara/exefiles.c
  libyara/filemap.c
  libyara/grammar.c
  libyara/hash.c
  libyara/hex_grammar.c
  libyara/hex_lexer.c
  libyara/lexer.c
  libyara/libyara.c
  libyara/mem.c
  libyara/modules.c
  libyara/modules/console/console.c
  libyara/modules/hash/hash.c
  libyara/modules/math/math.c
  libyara/modules/macho/macho.c
  libyara/modules/pe/pe.c
  libyara/modules/pe/pe_utils.c
  libyara/modules/pe/authenticode-parser/authenticode.c
  libyara/modules/pe/authenticode-parser/certificate.c
  libyara/modules/pe/authenticode-parser/helper.c
  libyara/modules/pe/authenticode-parser/countersignature.c
  libyara/modules/pe/authenticode-parser/structs.c
  libyara/modules/tests/tests.c
  libyara/modules/time/time.c
  libyara/modules/string/string.c  
  libyara/notebook.c
  libyara/object.c
  libyara/parser.c
  libyara/proc.c
  ${PROC_PLATFORM_SOURCE}  
  libyara/re.c
  libyara/re_grammar.c
  libyara/re_lexer.c
  libyara/rules.c
  libyara/scan.c
  libyara/scanner.c
  libyara/sizedstr.c
  libyara/stack.c
  libyara/stopwatch.c
  libyara/stream.c
  libyara/strutils.c
  libyara/threading.c
  
  # Module elf request new library tlshc(https://github.com/avast/tlshc), the related upstream PR: https://github.com/VirusTotal/yara/pull/1624.
  # libyara/modules/elf/elf.c
  # libyara/tlshc/tlsh.c
  # libyara/tlshc/tlsh_impl.c
  # libyara/tlshc/tlsh_util.c
)

set(
  yara_sources
  cli/args.c
  cli/common.c
  cli/threading.c
  cli/yara.c
)
set( yarac_sources
  cli/args.c
  cli/common.c
  cli/yarac.c
)

find_package(Threads REQUIRED)

set(
  libyara_dependencies 
  OpenSSL::SSL
  OpenSSL::Crypto 
  Threads::Threads
)

if(CMAKE_SYSTEM_NAME MATCHES "Windows")
list(APPEND libyara_dependencies Crypt32.lib Ws2_32.lib)
endif()
if(HAVE_LIBM)
  list(APPEND libyara_dependencies m)
endif()

set(
  libyara_definitions
  -DHAVE_LIBCRYPTO
  -D${PROC_PLATFORM_INTERFACE}
  -DHASH_MODULE
)

if(CUCKOO_MODULE)
  list(APPEND libyara_definitions -DCUCKOO_MODULE)
  list(APPEND libyara_sources libyara/modules/cuckoo/cuckoo.c)
  find_package(jansson CONFIG REQUIRED)
  list(APPEND libyara_dependencies jansson::jansson)
endif()

if(DOTNET_MODULE)
  list(APPEND libyara_definitions -DDOTNET_MODULE)
  list(APPEND libyara_sources libyara/modules/dotnet/dotnet.c libyara/simple_str.c)
endif()

add_library(libyara ${libyara_sources})
target_link_libraries(libyara PRIVATE ${libyara_dependencies})
target_compile_definitions(libyara PRIVATE ${libyara_definitions})
target_include_directories(libyara INTERFACE $<INSTALL_INTERFACE:include>)

add_executable(yara  ${yara_sources})
add_executable(yarac  ${yarac_sources})

target_link_libraries(yarac PRIVATE libyara ${libyara_dependencies})
target_link_libraries(yara PRIVATE libyara ${libyara_dependencies})

install(
  TARGETS libyara EXPORT unofficial-libyaraTargets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-libyaraTargets
    NAMESPACE unofficial::libyara::
    DESTINATION share/unofficial-libyara
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libyara-config.cmake.in"
[[include(CMakeFindDependencyMacro)
find_dependency(OpenSSL)
find_dependency(Threads)
if(@CUCKOO_MODULE@)
  find_dependency(jansson CONFIG)
endif()
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-libyaraTargets.cmake")
]])
configure_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-libyara-config.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/unofficial-libyara-config.cmake" @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-libyara-config.cmake DESTINATION share/unofficial-libyara)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS yarac yara
    RUNTIME DESTINATION tools/yara
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY libyara/include/ DESTINATION include)
endif()
