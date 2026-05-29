file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(WARNING "find_package(${CMAKE_FIND_PACKAGE_NAME}) is deprecated. Use find_package(unofficial-openvpn3) instead.")
include(CMakeFindDependencyMacro)
find_dependency(unofficial-openvpn3 CONFIG)
