find_path(OGG_INCLUDE_DIR NAMES ogg/ogg.h)

find_library(OGG_LIBRARY NAMES ogg libogg)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OGG DEFAULT_MSG OGG_LIBRARY OGG_INCLUDE_DIR)

mark_as_advanced(OGG_INCLUDE_DIR OGG_LIBRARY)
