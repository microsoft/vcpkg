macro(vcpkg_define_function_overwrite_option FUNCTION_NAME)
option(VCPKG_ENABLE_${FUNCTION_NAME} "Enables override of the cmake function ${FUNCTION_NAME}." ON)
mark_as_advanced(VCPKG_ENABLE_${FUNCTION_NAME})
endmacro()

macro(vcpkg_enable_function_overwrite_guard FUNCTION_NAME ADDITIONAL_SUFFIX)
 if(NOT ${ARGN} EQUAL 2 AND NOT ${ARGN} EQUAL 1)
  message(FATAL_ERROR "vcpkg_enable_function_overwrite_guard not used correctly in ${FUNCTION_NAME}. Must have one or two arguments!")
 endif()
 if(DEFINED _vcpkg_${FUNCTION_NAME}${ADDITIONAL_SUFFIX}_guard)
   vcpkg_msg(FATAL_ERROR "${FUNCTION_NAME}" "INFINIT LOOP DETECT. Did you supply your own ${FUNCTION_NAME} override? \n \
             If yes: please set VCPKG_ENABLE_${FUNCTION_NAME} to off and call vcpkg_${FUNCTION_NAME} if you want to have vcpkg corrected behavior. \n \
             If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
  else()
    set(_vcpkg_${FUNCTION_NAME}${ADDITIONAL_SUFFIX}_guard ON)
  endif()
endmacro()

macro(vcpkg_disable_function_overwrite_guard FUNCTION_NAME ADDITIONAL_SUFFIX)
  if(NOT DEFINED _vcpkg_${FUNCTION_NAME}${ADDITIONAL_SUFFIX}_guard)
    message(FATAL_ERROR "vcpkg_disable_function_overwrite_guard not used correctly in ${FUNCTION_NAME}!")
  endif()
  unset(_vcpkg_${FUNCTION_NAME}${ADDITIONAL_SUFFIX}_guard)
endmacro()