include_guard(GLOBAL)

get_filename_component(_ecbuild_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(ecbuild_ROOT "${_ecbuild_prefix}")
set(ecbuild_DIR "${_ecbuild_prefix}/share/ecbuild")
set(ecbuild_CMAKE_DIR "${_ecbuild_prefix}/share/ecbuild/cmake")
set(ECBUILD_MACROS_DIR "${ecbuild_CMAKE_DIR}")

if(NOT "${_ecbuild_prefix}" IN_LIST CMAKE_PREFIX_PATH)
    list(PREPEND CMAKE_PREFIX_PATH "${_ecbuild_prefix}")
endif()

if(NOT "${ecbuild_CMAKE_DIR}" IN_LIST CMAKE_MODULE_PATH)
    list(PREPEND CMAKE_MODULE_PATH "${ecbuild_CMAKE_DIR}")
endif()

unset(_ecbuild_prefix)
