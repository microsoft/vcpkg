# Findimgui.cmake
#
# Finds ImGui library
# Written by imgui-sfml
#
# This will define the following variables
# IMGUI_FOUND
# IMGUI_INCLUDE_DIRS
# IMGUI_SOURCES
# IMGUI_DEMO_SOURCES
# IMGUI_VERSION

list(APPEND IMGUI_SEARCH_PATH
  ${_IMPORT_PREFIX}
)

find_path(IMGUI_INCLUDE_DIR
  NAMES imgui.h
  PATHS ${IMGUI_SEARCH_PATH}
)

if(NOT IMGUI_INCLUDE_DIR)
  message(FATAL_ERROR "IMGUI imgui.cpp not found. Set IMGUI_DIR to imgui's top-level path (containing \"imgui.cpp\" and \"imgui.h\" files).\n")
endif()

set(IMGUI_INCLUDE_DIRS ${IMGUI_INCLUDE_DIR})

set(IMGUI_SOURCES
  ${IMGUI_INCLUDE_DIR}/imgui.cpp
  ${IMGUI_INCLUDE_DIR}/imgui_draw.cpp
  ${IMGUI_INCLUDE_DIR}/imgui_widgets.cpp
  ${IMGUI_INCLUDE_DIR}/misc/cpp/imgui_stdlib.cpp
)

set(IMGUI_DEMO_SOURCES
  ${IMGUI_INCLUDE_DIR}/imgui_demo.cpp
)

# Extract version from header
file(
  STRINGS
  ${IMGUI_INCLUDE_DIR}/imgui.h
  IMGUI_VERSION
  REGEX "#define IMGUI_VERSION "
)

if(NOT IMGUI_VERSION)
  message(SEND_ERROR "Can't find version number in ${IMGUI_INCLUDE_DIR}/imgui.h.")
endif()
# Transform '#define IMGUI_VERSION "X.Y"' into 'X.Y'
string(REGEX REPLACE ".*\"(.*)\".*" "\\1" IMGUI_VERSION "${IMGUI_VERSION}")

set(IMGUI_FOUND TRUE)
message(STATUS "Found ImGui v${IMGUI_VERSION} in ${IMGUI_INCLUDE_DIR}")