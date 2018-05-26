cmake_minimum_required(VERSION 3.0)
project(theora LANGUAGES C)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")
FIND_PACKAGE(OGG REQUIRED)

file(GLOB HEADERS
  "include/theora/codec.h"
  "include/theora/theora.h"
  "include/theora/theoradec.h"
  "include/theora/theoraenc.h"
)

include_directories("include")
include_directories(${OGG_INCLUDE_DIR})

set(LIBTHEORA_COMMON
  "lib/apiwrapper.c"
  "lib/bitpack.c"
  "lib/dequant.c"
  "lib/fragment.c"
  "lib/idct.c"
  "lib/info.c"
  "lib/internal.c"
  "lib/state.c"
  "lib/quant.c"

  "lib/x86_vc/mmxfrag.c"
  "lib/x86_vc/mmxidct.c"
  "lib/x86_vc/mmxstate.c"
  "lib/x86_vc/x86cpu.c"
  "lib/x86_vc/x86state.c"
)

set(LIBTHEORA_ENC
  "lib/analyze.c"
  "lib/encapiwrapper.c"
  "lib/encfrag.c"
  "lib/encinfo.c"
  "lib/encode.c"
  "lib/enquant.c"
  "lib/fdct.c"
  "lib/huffenc.c"
  "lib/mathops.c"
  "lib/mcenc.c"
  "lib/rate.c"
  "lib/tokenize.c"

  "lib/x86_vc/mmxencfrag.c"
  "lib/x86_vc/mmxfdct.c"
  "lib/x86_vc/x86enc.c"
)

set(LIBTHEORA_DEC
  "lib/decapiwrapper.c"
  "lib/decinfo.c"
  "lib/decode.c"
  "lib/huffdec.c"
)

add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)

option(USE_X86 "Use x86 optimization" OFF)
if(USE_X86)
  add_definitions(-DOC_X86_ASM)
endif()

if (BUILD_SHARED_LIBS)
  add_definitions(-DLIBTHEORA_EXPORTS)
endif()

add_library(theora-common OBJECT ${LIBTHEORA_COMMON} ${HEADERS})
add_library(theora-enc OBJECT ${LIBTHEORA_ENC} ${HEADERS})
add_library(theora-dec OBJECT ${LIBTHEORA_DEC} ${HEADERS})

add_library(theora $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-enc> $<TARGET_OBJECTS:theora-dec> "libtheora.def")
target_link_libraries(theora ${OGG_LIBRARY})

add_library(theoraenc $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-enc> "win32/xmingw32/libtheoraenc-all.def")
target_link_libraries(theoraenc ${OGG_LIBRARY})

add_library(theoradec $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-dec> "win32/xmingw32/libtheoradec-all.def")
target_link_libraries(theoradec ${OGG_LIBRARY})

install(FILES ${HEADERS} DESTINATION include/theora)

install(TARGETS theora theoraenc theoradec
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION bin
  ARCHIVE DESTINATION lib
)
