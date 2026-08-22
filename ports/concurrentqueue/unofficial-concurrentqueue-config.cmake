message(WARNING [[
'find_package(unofficial-concurrentqueue)' is deprecated. Please use

  find_package(concurrentqueue CONFIG)
  target_link_libraries(main PRIVATE concurrentqueue::concurrentqueue)
  #include <moodycamel/concurrentqueue.h>
]])
include(CMakeFindDependencyMacro)
find_dependency(concurrentqueue)
if(NOT TARGET unofficial::concurrentqueue::concurrentqueue)
    add_library(#[[skip-usage-heuristics]] unofficial::concurrentqueue::concurrentqueue IMPORTED INTERFACE)
    set_target_properties(unofficial::concurrentqueue::concurrentqueue PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include/concurrentqueue/unofficial"
        INTERFACE_LINK_LIBRARIES concurrentqueue::concurrentqueue
    )
endif()
