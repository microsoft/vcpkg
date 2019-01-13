find_path(TBB_INCLUDE_DIR tbb.h)

find_library(TBB_LIBRARY_DEBUG NAMES tbbd)
find_library(TBB_LIBRARY_RELEASE NAMES tbb)

include(SelectLibraryConfigurations)
select_library_configurations(TBB)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    TBB DEFAULT_MSG
    TBB_LIBRARY TBB_INCLUDE_DIR
)
