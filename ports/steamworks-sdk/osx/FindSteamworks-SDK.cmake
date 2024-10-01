include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(STEAMWORKS_SDK_INCLUDE_DIR
        NAMES steam/steam_api.h
        PATH_SUFFIXES public
        DOC "The Steamworks SDK include directory"
)

find_library(STEAMWORKS_SDK_LIBRARY
        NAMES libsteam_api.dylib
        PATH_SUFFIXES redistributable_bin/osx
        DOC "The Steamworks SDK library"
)

find_package_handle_standard_args(Steamworks-SDK DEFAULT_MSG STEAMWORKS_SDK_INCLUDE_DIR STEAMWORKS_SDK_LIBRARY)

mark_as_advanced(STEAMWORKS_SDK_INCLUDE_DIR STEAMWORKS_SDK_LIBRARY)