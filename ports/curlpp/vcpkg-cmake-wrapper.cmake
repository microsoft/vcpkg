set(FIND_CURLPP_ARGS ${ARGS})
include(CMakeFindDependencyMacro)
find_dependency(CURL)

_find_package(${FIND_CURLPP_ARGS})
