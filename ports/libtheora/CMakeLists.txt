project(theora)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")
FIND_PACKAGE(OGG REQUIRED)

file(GLOB HEADERS
"include/theora/codec.h"
"include/theora/theora.h"
"include/theora/theoradec.h"
)


include_directories("include")
include_directories(${OGG_INCLUDE_DIR})

file(GLOB SOURCES
"lib/analyze.c"
"lib/encapiwrapper.c"
"lib/encfrag.c"
"lib/encinfo.c"
"lib/encode.c"
#"lib/encoder_disabled.c"
"lib/enquant.c"
"lib/fdct.c"
"lib/huffenc.c"
"lib/mathops.c"
"lib/mcenc.c"
"lib/rate.c"
"lib/tokenize.c"
"lib/x86_vc/mmxencfrag.c"
"lib/x86_vc/mmxfdct.c"
"lib/x86_vc/x86cpu.c"
"lib/x86_vc/x86enc.c"
"lib/apiwrapper.c"
"lib/bitpack.c"
"lib/decapiwrapper.c"
"lib/decinfo.c"
"lib/decode.c"
"lib/dequant.c"
"lib/fragment.c"
"lib/huffdec.c"
"lib/idct.c"
"lib/info.c"
"lib/internal.c"
"lib/quant.c"
"lib/state.c"
"lib/x86_vc/mmxfrag.c"
"lib/x86_vc/mmxidct.c"
"lib/x86_vc/mmxstate.c"
"lib/x86_vc/x86state.c"
"win32/xmingw32/libtheoradec-all.def"
)

add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -D_BIND_TO_CURRENT_CRT_VERSION)
if (${BUILD_SHARED_LIBS})
	add_definitions(-DLIBTHEORA_EXPORTS)
endif()

add_library(theora ${SOURCES} ${HEADERS})
target_link_libraries(theora ${OGG_LIBRARY})

install(FILES ${HEADERS} DESTINATION include/theora)

install(TARGETS theora
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION bin
  ARCHIVE DESTINATION lib
)
