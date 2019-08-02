vcpkg_define_function_overwrite_option(link_libraries)

function(vcpkg_link_libraries)

  #get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
  #if( _CMAKE_IN_TRY_COMPILE )
  #	  _link_libraries(${ARGV})
#	 return()
#  endif()
  
  vcpkg_check_linkage(_vcpkg_check_linkage ${ARGV})
  _link_libraries(${_vcpkg_check_linkage})
endfunction()

if(VCPKG_ENABLE_link_libraries)
    function(link_libraries)
        vcpkg_enable_function_overwrite_guard(link_libraries "")

        vcpkg_link_libraries(${ARGV})

        vcpkg_disable_function_overwrite_guard(link_libraries "")
    endfunction()
endif()