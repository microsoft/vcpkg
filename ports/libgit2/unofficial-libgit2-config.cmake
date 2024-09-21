include("${CMAKE_CURRENT_LIST_DIR}/unofficial-libgit2-targets.cmake")
add_library(unofficial::libgit2::libgit2 INTERFACE IMPORTED)
set_target_properties(unofficial::libgit2::libgit2 PROPERTIES INTERFACE_LINK_LIBRARIES unofficial::libgit2::libgit2package)
