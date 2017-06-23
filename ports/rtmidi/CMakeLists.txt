cmake_minimum_required(VERSION 3.8)
project(rtmidi CXX)
set(RTMIDI_SOURCES
  ${PROJECT_SOURCE_DIR}/RtMidi.cpp
  ${PROJECT_SOURCE_DIR}/rtmidi_c.cpp
)

set(RTMIDI_HEADERS
  ${PROJECT_SOURCE_DIR}/RtMidi.h
  ${PROJECT_SOURCE_DIR}/rtmidi_c.h
)

include_directories(${RTMIDI_HEADERS})

if(BUILD_SHARED_LIBS)
  add_library(rtmidi SHARED ${RTMIDI_SOURCES})
  target_compile_definitions(rtmidi PRIVATE -DRTMIDI_EXPORT)
else()
  add_library(rtmidi STATIC ${RTMIDI_SOURCES})
endif()


file(READ "${PROJECT_SOURCE_DIR}/rtmidi_c.h" RTMIDI_EXPORT)
if (BUILD_SHARED)
  string(REPLACE "if defined(RTMIDI_EXPORT)" "if 1" RTMIDI_EXPORT "${RTMIDI_EXPORT}")
else()
  string(REPLACE "if defined(RTMIDI_EXPORT)" "if 0" RTMIDI_EXPORT "${RTMIDI_EXPORT}")
endif()
file(WRITE "${PROJECT_BINARY_DIR}/rtmidi_c.h" "${RTMIDI_EXPORT}")

install(
  TARGETS rtmidi
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES "${PROJECT_SOURCE_DIR}/RtMidi.h" DESTINATION include)
  install(FILES "${PROJECT_BINARY_DIR}/rtmidi_c.h" DESTINATION include)
endif()
