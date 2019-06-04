
include(SelectLibraryConfigurations)
find_path(PCRE_INCLUDE_DIR pcre.h)
set(PCRE_INCLUDE_DIRS ${PCRE_INCLUDE_DIR})
find_library(PCRE_LIBRARY_DEBUG NAMES pcred pcre NAMES_PER_DIR)
find_library(PCRE_LIBRARY_RELEASE pcre NAMES_PER_DIR)
select_library_configurations(PCRE)