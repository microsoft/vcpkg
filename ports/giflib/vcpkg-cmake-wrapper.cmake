_find_package(unofficial-giflib CONFIG REQUIRED)
if(NOT TARGET GIF::GIF)
    add_library(GIF::GIF ALIAS unofficial::giflib::gif)
endif()

get_filename_component(GIF_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(GIF_INCLUDE_DIRS "${GIF_INCLUDE_DIRS}" PATH)

set(GIF_FOUND TRUE)
set(GIF_INCLUDE_DIRS "${GIF_INCLUDE_DIRS}/include")
set(GIF_LIBRARIES unofficial::giflib::gif)
set(GIF_VERSION @GIFLIB_VERSION@)
