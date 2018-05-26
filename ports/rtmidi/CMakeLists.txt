cmake_minimum_required(VERSION 3.8)
project(rtmidi CXX)

add_library(rtmidi RtMidi.cpp rtmidi_c.cpp)
if(BUILD_SHARED_LIBS)
  target_compile_definitions(rtmidi PRIVATE -DRTMIDI_EXPORT)
endif()

file(READ "${PROJECT_SOURCE_DIR}/rtmidi_c.h" RTMIDI_EXPORT)
if (BUILD_SHARED_LIBS)
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
  install(FILES "RtMidi.h" DESTINATION include)
  install(FILES "${PROJECT_BINARY_DIR}/rtmidi_c.h" DESTINATION include)
endif()
