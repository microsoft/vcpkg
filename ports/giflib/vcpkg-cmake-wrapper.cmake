_find_package(unofficial-giflib CONFIG REQUIRED)
add_library(GIF::GIF ALIAS unofficial::giflib::gif)

get_filename_component(GIF_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(GIF_INCLUDE_DIRS "${LUA_INCLUDE_DIR}" PATH)

set(GIF_FOUND TRUE)
set(GIF_INCLUDE_DIRS ${_IMPORT_PREFIX}/include)
set(GIF_LIBRARIES unofficial::giflib::gif)
set(GIF_VERSION @GIFLIB_VERSION@)

unset(_IMPORT_PREFIX)
