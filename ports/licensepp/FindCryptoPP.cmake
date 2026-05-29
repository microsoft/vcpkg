find_path(CRYPTOPP_INCLUDE_DIRS NAMES cryptopp/cryptlib.h)

get_filename_component(_prefix_path ${CRYPTOPP_INCLUDE_DIRS} PATH)

find_library(
    CRYPTOPP_LIBRARY_DEBUG
    NAMES cryptopp-static cryptopp
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)
find_library(
    CRYPTOPP_LIBRARY_RELEASE
    NAMES cryptopp-static cryptopp
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(CRYPTOPP)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CryptoPP
    REQUIRED_VARS CRYPTOPP_LIBRARIES CRYPTOPP_INCLUDE_DIRS
)
