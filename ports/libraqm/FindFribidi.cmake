find_path(FRIBIDI_INCLUDE_DIR
          NAMES fribidi/fribidi.h)

set(FRIBIDI_INCLUDE_DIR "${FRIBIDI_INCLUDE_DIR}/fribidi")
find_library(FRIBIDI_LIBRARY NAMES fribidi)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FriBidi 
    FOUND_VAR FRIBIDI_FOUND
    REQUIRED_VARS  FRIBIDI_LIBRARY FRIBIDI_INCLUDE_DIR
    VERSION_VAR FRIBIDI_VERSION_STRING    
)