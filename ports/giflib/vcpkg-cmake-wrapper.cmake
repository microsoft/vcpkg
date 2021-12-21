include(SelectLibraryConfigurations)
find_path(GIF_INCLUDE_DIR gif_lib.h PATH_SUFFIXES include PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH)

find_library(GIF_LIBRARY_DEBUG NAMES gif libgif ungif libungif giflib giflib4 gifd libgifd ungifd libungifd giflibd giflib4d NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH REQUIRED)
find_library(GIF_LIBRARY_RELEASE NAMES gif libgif ungif libungif giflib giflib4 NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH REQUIRED)
select_library_configurations(GIF)
set(GIF_INCLUDE_DIRS ${GIF_INCLUDE_DIR})
set(GIF_LIBRARIES ${GIF_LIBRARY})
set(GIF_VERSION 5)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GIF  REQUIRED_VARS  GIF_LIBRARY  GIF_INCLUDE_DIR
                                       VERSION_VAR GIF_VERSION )

if(NOT TARGET GIF::GIF)
  add_library(GIF::GIF UNKNOWN IMPORTED)
  set_target_properties(GIF::GIF PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GIF_INCLUDE_DIRS}")
  if(EXISTS "${GIF_LIBRARY}")
    set_target_properties(GIF::GIF PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION "${GIF_LIBRARY}")
  endif()
endif()
