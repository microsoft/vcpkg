list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE") # Always call CONFIG.
_find_package(${ARGS} CONFIG)
if(NOT TARGET LibLZMA::LibLZMA AND TARGET liblzma::liblzma)
    add_library(LibLZMA::LibLZMA INTERFACE IMPORTED) # Too lazy to fix wrong target usage all over vcpkg. 
    set_target_properties(LibLZMA::LibLZMA PROPERTIES INTERFACE_LINK_LIBRARIES liblzma::liblzma)
endif()
