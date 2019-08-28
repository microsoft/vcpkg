

function(vcpkg_check_linkage OUTPUT_LINK_LIST)
    #Match Start of Generator expression until first : without a new start of a generator expression -> should give the deepest nested :
    #Use MATCHALL and List length to determine
    set(_vcpkg_genexp_start "\\$<")
    set(_vcpkg_genexp_close "([^>]*>)") # closing > at the end of the expression
    #set(_vcpkg_genexp_opening "^(:?\\$<[^:]+)+:") # stops at deepest nested :
    set(_vcpkg_genexp_closing_begin "([^>]*>)+:|^\\$<[^:]+:") # stops at last : . After that the link path/target has to be
    set(_vcpkg_genexp_close_end "(>)+$") # closing > at the end of the expression

  get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
  #if( _CMAKE_IN_TRY_COMPILE)
  if( _CMAKE_IN_TRY_COMPILE)
     set(${OUTPUT_LINK_LIST} ${ARGN} PARENT_SCOPE)
     return()
  endif()
  
  unset(${OUTPUT_LINK_LIST} PARENT_SCOPE)
  set(_tmp_list)
  set(_tmp_gen_list)
  set(_tmp_cur_list _tmp_list)
  set(_genexp_counter 0)
  foreach(_vcpkg_link_lib ${ARGN})
    vcpkg_msg(STATUS "vcpkg_check_linkage" "Link element to check ${_vcpkg_link_lib}")
    
    if(${_vcpkg_link_lib} MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
        set(_vcpkg_check_link TRUE)
    else()
        set(_vcpkg_check_link FALSE)
    endif()
    
    #Generator expressions list guard
    if(${_vcpkg_link_lib} MATCHES ${_vcpkg_genexp_start})
        while(${_vcpkg_link_lib} MATCHES ${_vcpkg_genexp_start})
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Detected opening generator expression!")    
            string(REGEX MATCH ${_vcpkg_genexp_closing_begin} _vcpkg_link_lib_genexp_begin_tmp ${_vcpkg_link_lib})
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Found expression ${_vcpkg_link_lib_genexp_begin_tmp} at the start.")
            string(REGEX MATCHALL ${_vcpkg_genexp_start} _vcpkg_genexp_opening_match ${_vcpkg_link_lib_genexp_begin_tmp})
            string(REGEX MATCHALL ${_vcpkg_genexp_close} _vcpkg_genexp_close_match   ${_vcpkg_link_lib_genexp_begin_tmp})
            list(LENGTH _vcpkg_genexp_opening_match _vcpkg_genexp_opening_counter)
            list(LENGTH _vcpkg_genexp_close_match _vcpkg_genexp_closing_counter)
            unset(_vcpkg_genexp_opening_match)
            unset(_vcpkg_genexp_close_match)
            string(CONCAT _vcpkg_link_lib_genexp_begin ${_vcpkg_link_lib_genexp_begin} ${_vcpkg_link_lib_genexp_begin_tmp})
            
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Found ${_vcpkg_genexp_opening_counter} opening and ${_vcpkg_genexp_closing_counter} closing expressions.")

            math(EXPR _genexp_counter "${_genexp_counter} + ${_vcpkg_genexp_opening_counter} - ${_vcpkg_genexp_closing_counter}")    
            unset(_vcpkg_genexp_opening_counter)
            unset(_vcpkg_genexp_closing_counter)
            
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Genexpression remaining counter ${_genexp_counter}")       

            string(REPLACE "${_vcpkg_link_lib_genexp_begin_tmp}" "" _vcpkg_link_lib ${_vcpkg_link_lib}) # Remove starting genexp
            
            set(_tmp_cur_list _tmp_gen_list)      
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Link element to check changed to ${_vcpkg_link_lib} due to opening generator expression")
        endwhile()
    endif()
    
    if(${_vcpkg_link_lib} MATCHES ${_vcpkg_genexp_close_end})
        string(REGEX MATCH ${_vcpkg_genexp_close_end} _vcpkg_link_lib_genexp_close ${_vcpkg_link_lib})
        string(REGEX MATCHALL ${_vcpkg_genexp_close} _vcpkg_genexp_close_match ${_vcpkg_link_lib_genexp_close})
        list(LENGTH _vcpkg_genexp_close_match _vcpkg_genexp_close_counter)
        string(REPLACE "${_vcpkg_link_lib_genexp_close}" "" _vcpkg_link_lib ${_vcpkg_link_lib})

        math(EXPR _genexp_counter "${_genexp_counter} - ${_vcpkg_genexp_close_counter}")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Genexpression counter decreased ${_genexp_counter}")
        
        if(${_genexp_counter} EQUAL 0)
            set(_vcpkg_close_genexp 1)
        endif()
        if(${_genexp_counter} LESS 0)  
             vcpkg_msg(FATAL_ERROR "vcpkg_check_linkage" "Programming error. Expression counter below 0!")
        endif()
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Link element to check changed to ${_vcpkg_link_lib} due to closing generator expression")    
    endif()
    
    #Keyword check
    if(${_vcpkg_link_lib} MATCHES "(^debug$|^optimized$|^general$)")
      set(_vcpkg_link_lib_keyword ${_vcpkg_link_lib})
      vcpkg_msg(STATUS "vcpkg_check_linkage" "Setting keyword: ${_vcpkg_link_lib_keyword}!")
      continue()
    endif()

    #Linkage Check
    if(_vcpkg_check_link AND "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}(/debug/(lib|bin)|/(lib|bin))(/manual-link)*") 
        # Library picked up from VCPKG -> check and correct linkage if necessary
        vcpkg_extract_library_name_from_path(_vcpkg_libtrack_name ${_vcpkg_link_lib})
        if(("${_vcpkg_link_lib_keyword}" MATCHES "debug" OR 
            ("${_vcpkg_link_lib_genexp_begin}" MATCHES "\$<CONFIG:[Dd][Ee][Bb][Uu][Gg]>" AND
             NOT "${_vcpkg_link_lib_genexp_begin}" MATCHES "\$<NOT:\$<CONFIG:[Dd][Ee][Bb][Uu][Gg]>")) 
           AND NOT "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/(lib|bin)(/manual-link)*")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG)
                vcpkg_msg(WARNING "vcpkg_check_linkage" "Correcting debug linkage from ${_vcpkg_link_lib}!")
                set(${_vcpkg_link_lib} ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG})
                vcpkg_msg(WARNING "vcpkg_check_linkage" "to ${_vcpkg_link_lib}!")
            endif()
            vcpkg_msg(WARNING "vcpkg_check_linkage" "Wrong debug linkage: ${_vcpkg_link_lib}!") # should be correct if find_library did not screw up
        elseif(("${_vcpkg_link_lib_keyword}" MATCHES "optimized" OR
                "${_vcpkg_link_lib_genexp_begin}" MATCHES "\$<NOT:\$<CONFIG:[Dd][Ee][Bb][Uu][Gg]>")
               AND NOT "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/(lib|bin)(/manual-link)*")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE)
                vcpkg_msg(WARNING "vcpkg_check_linkage" "Correcting optimized linkage from ${_vcpkg_link_lib}!")
                set(${_vcpkg_link_lib} ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE})
                vcpkg_msg(WARNING "vcpkg_check_linkage" "to ${_vcpkg_link_lib}!")
            endif()
            vcpkg_msg(WARNING "vcpkg_check_linkage" "Wrong optimized linkage: ${_vcpkg_link_lib}!") # should be correct if find_library did not screw up
        elseif(${_vcpkg_link_lib_keyword} MATCHES "general" OR (NOT DEFINED _vcpkg_link_lib_keyword AND NOT DEFINED _vcpkg_link_lib_genexp_begin)) # means general or no keyword!
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Correcting general linkage option!")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG AND VCPKG_DEBUG_AVAILABLE)
                list(APPEND ${_tmp_cur_list} debug "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}")
            else()
                vcpkg_msg(WARNING "vcpkg_check_linkage" "VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG not available!")
            endif()
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE)
                list(APPEND ${_tmp_cur_list} optimized "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE}")
            else()
                vcpkg_msg(FATAL_ERROR "vcpkg_check_linkage" "VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE not available!")
            endif()
        else() #everything fine. Nothing to do 
            if(DEFINED _vcpkg_link_lib_keyword) # External LIB -> do nothing
              list(APPEND ${_tmp_cur_list} "${_vcpkg_link_lib_genexp_begin}${_vcpkg_link_lib_keyword}" "${_vcpkg_link_lib}${_vcpkg_link_lib_genexp_close}")
            else()
              list(APPEND ${_tmp_cur_list} "${_vcpkg_link_lib_genexp_begin}${_vcpkg_link_lib}${_vcpkg_link_lib_genexp_close}")
            endif()
        endif()
    elseif(DEFINED _vcpkg_link_lib_keyword) # External LIB -> do nothing
      vcpkg_msg(STATUS "vcpkg_check_linkage" "External library with keyword!")
      list(APPEND ${_tmp_cur_list} "${_vcpkg_link_lib_genexp_begin}${_vcpkg_link_lib_keyword}" "${_vcpkg_link_lib}${_vcpkg_link_lib_genexp_close}") # keywords do not exist in genex so no guard needed
    else()
      list(APPEND ${_tmp_cur_list} "${_vcpkg_link_lib_genexp_begin}${_vcpkg_link_lib}${_vcpkg_link_lib_genexp_close}")
    endif()
    
    #close generator expression
    if(_vcpkg_close_genexp)   
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Closing generator expression list!")
        set(_is_genex_list 0)
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Old List: ${_tmp_list}")
        list(JOIN _tmp_gen_list "\\\\\;" _tmp_glue_list)
        list(APPEND _tmp_list ${_tmp_glue_list})
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Gen List: ${_tmp_gen_list}")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "New List: ${_tmp_list}")
        unset(_tmp_gen_list)
        unset(_vcpkg_link_lib_genexp)
        unset(_vcpkg_close_genexp)
        set(_tmp_cur_list _tmp_list)
    endif()
    
    unset(_vcpkg_link_lib_keyword)
    unset(_vcpkg_link_lib_genexp_begin)
    unset(_vcpkg_link_lib_genexp_close)
  endforeach()
  vcpkg_msg(STATUS "vcpkg_check_linkage" "Link List: ${ARGN}")
  vcpkg_msg(STATUS "vcpkg_check_linkage" "checked List: ${_tmp_list}")
  set(${OUTPUT_LINK_LIST} ${_tmp_list} PARENT_SCOPE)
endfunction()
