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

set(
  libyara_sources
  libyara/ahocorasick.c
  libyara/arena.c
  libyara/atoms.c
  libyara/compiler.c
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
  libyara/modules/cuckoo.c
  libyara/modules/dotnet.c
  libyara/modules/elf.c
  libyara/modules/hash.c
  libyara/modules/math.c
  libyara/modules/macho.c
  libyara/modules/pe.c
  libyara/modules/pe_utils.c
  libyara/modules/tests.c
  libyara/modules/time.c
  libyara/object.c
  libyara/parser.c
  libyara/proc.c
  libyara/proc/windows.c
  libyara/re.c
  libyara/re_grammar.c
  libyara/re_lexer.c
  libyara/rules.c
  libyara/scan.c
  libyara/sizedstr.c
  libyara/stream.c
  libyara/strutils.c
  libyara/threading.c
)

set(
  yara_sources
  args.c
  threading.c
  yara.c
)
set( yarac_sources
  args.c
  yarac.c
)

add_library(libyara ${libyara_sources})

target_link_libraries(libyara PRIVATE OpenSSL::SSL OpenSSL::Crypto ${JANSSON_LIBRARY})
target_compile_definitions(
  libyara
  PRIVATE
  -DHAVE_LIBCRYPTO -DUSE_WINDOWS_PROC
  -DCUCKOO_MODULE- DHASH_MODULE -DDOTNET_MODULE
)


add_executable(yara  ${yara_sources})
add_executable(yarac  ${yarac_sources})

target_link_libraries(yarac PRIVATE libyara OpenSSL::SSL OpenSSL::Crypto ${JANSSON_LIBRARY})
target_link_libraries(yara PRIVATE libyara OpenSSL::SSL OpenSSL::Crypto ${JANSSON_LIBRARY})

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
