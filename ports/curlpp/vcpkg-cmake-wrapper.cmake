set(FIND_CURLPP_ARGS ${ARGS})
include(CMakeFindDependencyMacro)
find_dependency(CURL)

z_vcpkg_underlying_find_package(${FIND_CURLPP_ARGS})
