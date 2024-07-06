# Need to keep this file due to vcpkg.cmake otherwise injecting a different behavior.
set(Boost_NO_BOOST_CMAKE OFF)
vcpkg_underlying_find_package(${ARGS})