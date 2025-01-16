set(program_name ninja)
if(NOT NINJA)
  vcpkg_execute_in_download_mode(
      COMMAND "$ENV{VCPKG_COMMAND}" fetch ninja
      RESULT_VARIABLE error_code
      OUTPUT_VARIABLE NINJA
      WORKING_DIRECTORY "${DOWNLOADS}"
  )
  string(STRIP "${NINJA}" NINJA)
  set(NINJA "${NINJA}" CACHE STRING "" FORCE)
endif()
