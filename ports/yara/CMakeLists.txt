cmake_minimum_required(VERSION 3.8)
project(yara C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()


find_package(OpenSSL REQUIRED)
find_path(JANSSON_INCLUDE_DIR NAMES jansson.h)
find_library(JANSSON_LIBRARY NAMES jansson)


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
  libyara/modules/cuckoo/cuckoo.c
  libyara/modules/dotnet/dotnet.c
  libyara/modules/elf/elf.c
  libyara/modules/hash/hash.c
  libyara/modules/math/math.c
  libyara/modules/macho/macho.c
  libyara/modules/pe/pe.c
  libyara/modules/pe/pe_utils.c
  libyara/modules/tests/tests.c
  libyara/modules/time/time.c
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
)

set(
  yara_sources
  cli/args.c
  cli/threading.c
  cli/yara.c
)
set( yarac_sources
  cli/args.c
  cli/yarac.c
)


find_package(Threads REQUIRED)

set(
  libyara_dependencies 
  OpenSSL::SSL
  OpenSSL::Crypto 
  Threads::Threads
  ${JANSSON_LIBRARY}
)

IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
list(APPEND libyara_dependencies Crypt32.lib Ws2_32.lib)
endif()
if("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND libyara_dependencies m)
endif()

set(
  libyara_definitions
  -DHAVE_LIBCRYPTO
  -D${PROC_PLATFORM_INTERFACE}
  -DCUCKOO_MODULE
  -DHASH_MODULE
  -DDOTNET_MODULE
)

add_library(libyara ${libyara_sources})
target_link_libraries(libyara PRIVATE ${libyara_dependencies})
target_compile_definitions(libyara PRIVATE ${libyara_definitions})


add_executable(yara  ${yara_sources})
add_executable(yarac  ${yarac_sources})

target_link_libraries(yarac PRIVATE libyara ${libyara_dependencies})
target_link_libraries(yara PRIVATE libyara ${libyara_dependencies})

install(
  TARGETS libyara
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS yarac yara
    RUNTIME DESTINATION tools/yara
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY libyara/include/ DESTINATION include)
endif()
