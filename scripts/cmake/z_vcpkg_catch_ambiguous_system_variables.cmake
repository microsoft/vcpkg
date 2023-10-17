function(z_vcpkg_catch_ambiguous_system_variables VARIABLE ACCESS VALUE POS STACK)
    message(FATAL_ERROR "Unexpected ${ACCESS} on variable ${VARIABLE} in script mode.
This variable name insufficiently expresses whether it refers to the \
target system or to the host system. Use a prefixed variable instead.
- Variables providing information about the host:
  CMAKE_HOST_<SYSTEM>
  VCPKG_HOST_IS_<SYSTEM>
- Variables providing information about the target:
  VCPKG_TARGET_IS_<SYSTEM>
  VCPKG_DETECTED_<VARIABLE> (using vcpkg_cmake_get_vars)
")
endfunction()

set(VCPKG_AMBIGUOUS_SYSTEM_VARIABLES "" CACHE STRING "Variables which must not be used in portfiles")
foreach(var IN LISTS VCPKG_AMBIGUOUS_SYSTEM_VARIABLES)
    variable_watch("${var}" z_vcpkg_catch_ambiguous_system_variables)
endforeach()
