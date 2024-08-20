file(READ "${CMAKE_CURRENT_LIST_DIR}/../argon2/usage" usage)
message(WARNING "find_package(unofficial-libargon2) is deprecated.\n${usage}")
include(CMakeFindDependencyMacro)
find_dependency(unofficial-argon2 CONFIG)
