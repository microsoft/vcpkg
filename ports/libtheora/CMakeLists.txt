cmake_minimum_required(VERSION 3.0)
project(theora LANGUAGES C)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")
find_package(Ogg CONFIG REQUIRED)

file(GLOB HEADERS
  "include/theora/codec.h"
  "include/theora/theora.h"
  "include/theora/theoradec.h"
  "include/theora/theoraenc.h"
)

if(MSVC)
  set(LIBTHEORA_COMMON_X86
    "lib/x86_vc/mmxfrag.c"
    "lib/x86_vc/mmxidct.c"
    "lib/x86_vc/mmxstate.c"
    "lib/x86_vc/x86cpu.c"
    "lib/x86_vc/x86state.c"
  )
else()
  set(LIBTHEORA_COMMON_X86
    "lib/x86/mmxfrag.c"
    "lib/x86/mmxidct.c"
    "lib/x86/mmxstate.c"
    "lib/x86/sse2idct.c"
    "lib/x86/x86cpu.c"
    "lib/x86/x86state.c"
  )
endif()

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

  ${LIBTHEORA_COMMON_X86}
)

if(MSVC)
  set(LIBTHEORA_ENC_X86
    "lib/x86_vc/mmxencfrag.c"
    "lib/x86_vc/mmxfdct.c"
    "lib/x86_vc/x86enc.c"
  )
else()
  set(LIBTHEORA_ENC_X86
    "lib/x86/mmxencfrag.c"
    "lib/x86/mmxfdct.c"
    "lib/x86/x86enc.c"
    "lib/x86/x86enquant.c"
    "lib/x86/sse2encfrag.c"
  )
endif()

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

  ${LIBTHEORA_ENC_X86}
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
target_link_libraries(theora-common PUBLIC Ogg::ogg)
target_include_directories(theora-common PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
add_library(theora-enc OBJECT ${LIBTHEORA_ENC} ${HEADERS})
target_link_libraries(theora-enc PUBLIC Ogg::ogg)
target_include_directories(theora-enc PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
add_library(theora-dec OBJECT ${LIBTHEORA_DEC} ${HEADERS})
target_link_libraries(theora-dec PUBLIC Ogg::ogg)
target_include_directories(theora-dec PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

add_library(theora $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-enc> $<TARGET_OBJECTS:theora-dec> "libtheora.def")
target_link_libraries(theora PUBLIC Ogg::ogg)
target_include_directories(theora PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

add_library(theoraenc $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-enc> "win32/xmingw32/libtheoraenc-all.def")
target_link_libraries(theoraenc PUBLIC Ogg::ogg)
target_include_directories(theoraenc PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

add_library(theoradec $<TARGET_OBJECTS:theora-common> $<TARGET_OBJECTS:theora-dec> "win32/xmingw32/libtheoradec-all.def")
target_link_libraries(theoradec PUBLIC Ogg::ogg)
target_include_directories(theoradec PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

include(CMakePackageConfigHelpers)

configure_package_config_file(unofficial-theora-config.cmake.in unofficial-theora-config.cmake
  INSTALL_DESTINATION "lib/unofficial-theora")

install(FILES ${HEADERS} DESTINATION include/theora)

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-theora-config.cmake"
  DESTINATION "lib/unofficial-theora"
)

install(TARGETS theora theoraenc theoradec
  EXPORT unofficial-theora-targets
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

install(EXPORT unofficial-theora-targets
  NAMESPACE unofficial::theora::
  DESTINATION "lib/unofficial-theora"
)

set(prefix "${CMAKE_INSTALL_PREFIX}")
set(libdir "\${prefix}/lib")
set(exec_prefix "\${prefix}")
set(includedir "\${prefix}/include")
configure_file(theora.pc.in theora.pc @ONLY)
configure_file(theoradec.pc.in theoradec.pc @ONLY)
configure_file(theoraenc.pc.in theoraenc.pc @ONLY)

install(
  FILES "${PROJECT_BINARY_DIR}/theora.pc" "${PROJECT_BINARY_DIR}/theoradec.pc" "${PROJECT_BINARY_DIR}/theoraenc.pc"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
