#set(Boost_USE_STATIC_LIBS OFF)
#set(Boost_USE_MULTITHREADED ON)
# Need to keep this file due to vcpkg.cmake otherwise injecting a different behavior.
_find_package(${ARGS})