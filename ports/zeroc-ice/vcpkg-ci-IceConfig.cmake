enable_language(CXX)
set(Ice_DEBUG 1)
include(CMakeFindDependencyMacro)
find_dependency(Ice COMPONENTS Ice++11)
set(vcpkg-ci-zeroc-ice_LIBRARIES "${Ice_LIBRARIES}")

message(FATAL_ERROR STOP)
