# Old policies on purpose: with CMP0099 OLD, as in ParaView, link directories of
# $<LINK_ONLY:...> dependencies are dropped, so this checks that MUMPS's static
# Fortran runtime still links.
cmake_minimum_required(VERSION 3.12...3.16)
project(pagmo2-test CXX)

find_package(pagmo CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE Pagmo::pagmo)
install(TARGETS main RUNTIME DESTINATION "bin/vcpkg-ci-pagmo2")
