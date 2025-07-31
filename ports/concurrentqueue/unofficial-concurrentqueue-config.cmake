message(WARNING [[
'find_package(unofficial-concurrentqueue) is deprecated.'
Please use 'find_package(concurrentqueue CONFIG)' instead.
]]
include(CMakeFindDependencyMacro)
find_dependency(concurrentqueue)
if(NOT TARGET unofficial::concurrentqueue::concurrentqueue)
    add_library( #[[deprecated]] unofficial::concurrentqueue::concurrentqueue ALIAS concurrentqueue::concurrentqueue)
endif()
