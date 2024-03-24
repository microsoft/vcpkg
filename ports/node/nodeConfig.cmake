add_library(node INTERFACE IMPORTED)

# Set the include directories for both debug and release configurations
set_target_properties(node PROPERTIES INTERFACE_INCLUDE_DIRECTORIES 
    "${CMAKE_CURRENT_LIST_DIR}/../../include" # this is advice postion
    "${CMAKE_CURRENT_LIST_DIR}/../../include/node" # this is easy for process.cc compile
)

# Set the location of the library for debug configuration
set_target_properties(node PROPERTIES
    IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/libnode.so.122"
)

# Set the location of the library for release configuration
set_target_properties(node PROPERTIES
    IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "${CMAKE_CURRENT_LIST_DIR}/../../lib/libnode.so.122"
)