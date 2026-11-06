include_guard(GLOBAL)

get_filename_component(_ecbuild_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(ENV{ecbuild_ROOT} "${_ecbuild_prefix}")
unset(_ecbuild_prefix)
