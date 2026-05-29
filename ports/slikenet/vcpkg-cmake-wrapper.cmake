_find_package(${ARGS})

if(NOT TARGET SLikeNet AND TARGET SLikeNetDLL)
add_library(SLikeNet INTERFACE IMPORTED)
set_target_properties(SLikeNet PROPERTIES INTERFACE_LINK_LIBRARIES SLikeNetDLL)
endif()

if(NOT TARGET SLikeNet AND TARGET SLikeNetLibStatic)
add_library(SLikeNet INTERFACE IMPORTED)
set_target_properties(SLikeNet PROPERTIES INTERFACE_LINK_LIBRARIES SLikeNetLibStatic)
endif()
