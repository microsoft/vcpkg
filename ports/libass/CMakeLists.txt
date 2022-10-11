cmake_minimum_required(VERSION 3.9)
project(libass C CXX)

set(LIBASS_VERSION 0.16.0)

configure_file (${CMAKE_CURRENT_SOURCE_DIR}/config.h.in config.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

add_compile_definitions(CONFIG_FREETYPE)
add_compile_definitions(CONFIG_FRIBIDI)
add_compile_definitions(CONFIG_HARFBUZZ)

file (GLOB_RECURSE SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/libass/*.c)

include(CheckCSourceCompiles)
set(PKG_REQUIRES_LIBASS "harfbuzz >= 1.2.3, fribidi >= 0.19.1, freetype2 >= 9.17.3")
set(PKG_LIBS_LIBASS)
if(WIN32)
  add_compile_definitions(CONFIG_DIRECTWRITE)
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_coretext.c$")
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_fontconfig.c$")

  #dependency fribidi does not support uwp builds, link gdi32 directly
  set(FONT_LIBRARY gdi32)
  set(PKG_LIBS_LIBASS -lgdi32)
elseif(APPLE)
  add_compile_definitions(CONFIG_CORETEXT)
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_directwrite.c$")
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_fontconfig.c$")

  check_c_source_compiles(
    "
    #include <ApplicationServices/ApplicationServices.h>
    int main(void){
      CTFontDescriptorCopyAttribute(NULL, kCTFontURLAttribute);
      return 0;
    }
    "
    CHECK_OLD_OSX
  )
  if (CHECK_OLD_OSX)
    set(FONT_LIBRARY "-framework ApplicationServices -framework CoreFoundation")
    set(PKG_LIBS_LIBASS "-framework ApplicationServices -framework CoreFoundation")
  else()
    set(FONT_LIBRARY "-framework CoreText -framework CoreFoundation")
    set(PKG_LIBS_LIBASS "-framework CoreText -framework CoreFoundation")
  endif()
else()
  add_compile_definitions(CONFIG_FONTCONFIG)
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_coretext.c$")
  list(FILTER SOURCES EXCLUDE REGEX ".*ass_directwrite.c$")

  find_package(Fontconfig REQUIRED)
  set(FONT_LIBRARY Fontconfig::Fontconfig)
  set(PKG_REQUIRES_LIBASS "fontconfig >= 2.10.92, ${PKG_REQUIRES_LIBASS}")
endif()

if (NOT WIN32)
  set(PKG_LIBS_LIBASS "${PKG_LIBS_LIBASS} -lm")
endif()

find_package(Freetype REQUIRED)

find_path(FRIBIDI_INCLUDE_DIR
          NAMES fribidi.h
          PATH_SUFFIXES fribidi)

find_path(HARFBUZZ_INCLUDE_DIR
          NAMES hb.h
          PATH_SUFFIXES harfbuzz)

# libass use win32 api to open files on windows since https://github.com/libass/libass/commit/f664ced049394e2a5d4300ba526e206df73ec729
# so remove dependency dirent.

find_library(FRIBIDI_LIBRARY NAMES libfribidi fribidi)
find_library(HARFBUZZ_LIBRARY NAMES harfbuzz)

add_library(ass ${SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/libass.def)

target_include_directories(ass PRIVATE
  ${FRIBIDI_INCLUDE_DIR}
  ${HARFBUZZ_INCLUDE_DIR})
if(DIRENT_INCLUDE_DIR)
    target_include_directories(ass PRIVATE
      ${DIRENT_INCLUDE_DIR})
endif()
target_link_libraries(ass PRIVATE
  Freetype::Freetype
  ${FRIBIDI_LIBRARY}
  ${HARFBUZZ_LIBRARY}
  ${FONT_LIBRARY})

install(TARGETS ass
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

# pkgconfig file
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/lib)
set(includedir ${CMAKE_INSTALL_PREFIX}/include)
set(PACKAGE_VERSION ${LIBASS_VERSION})
if(BUILD_SHARED_LIBS)
  set(PKG_REQUIRES_PRIVATE ${PKG_REQUIRES_LIBASS})
  set(PKG_LIBS_PRIVATE ${PKG_LIBS_LIBASS})
else()
  set(PKG_REQUIRES_PUBLIC ${PKG_REQUIRES_LIBASS})
  set(PKG_LIBS_PUBLIC ${PKG_LIBS_LIBASS})
endif()
configure_file(libass.pc.in libass.pc @ONLY)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/libass.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
