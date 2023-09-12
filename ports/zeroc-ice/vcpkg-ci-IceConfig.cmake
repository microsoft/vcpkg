set(Ice_DEBUG 1)
include(CMakeFindDependencyMacro)
find_dependency(Ice COMPONENTS Ice)
set(vcpkg-ci-zeroc-ice_LIBRARIES "${Ice_LIBRARIES}")
