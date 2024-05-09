include_guard(GLOBAL)

function(vcpkg_download_from_json)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "JSONS")
  if(DEFINED arg_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "vcpkg_cmake_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT arg_JSONS)
    list(APPEND arg_JSONS "${CMAKE_CURRENT_LIST_DIR}/download.json")
  endif()

  foreach(json IN LISTS arg_JSONS)
    z_vcpkg_download_from_json(vars "${json}")
  endforeach()
  
  foreach(o IN LISTS vars)
    set("${o}" "${${o}}" PARENT_SCOPE)
  endforeach()
endfunction()

function(z_vcpkg_download_from_json outs json_file)
  file(READ "${json_file}" json_data)
  z_read_json_member(outvars "${json_data}" "downloads")

  #foreach(o IN LISTS outvars)
  #  message("${o}=${${o}}")
  #endforeach()

  set(out "")

  foreach(download_item IN LISTS downloads.index_list)
    set(prefix downloads.${download_item})
    foreach(member IN LISTS ${prefix}.members) # Expand all CMake variables in members
      string(CONFIGURE "${${prefix}.${member}}" "${prefix}.${member}" ESCAPE_QUOTES)
    endforeach()

    cmake_language(CALL z_vcpkg_download_from_${${prefix}.from} "${prefix}")
    list(APPEND out "${${prefix}.output-variable}")
    
    if(${prefix}.copy-to) # Check --editable?
      file(REMOVE_RECURSE ${${prefix}.copy-to})
      # Would like to use rename here ?
      file(COPY "${${${prefix}.output-variable}}/" DESTINATION "${${prefix}.copy-to}")
      set("${${prefix}.output-variable}" "${${prefix}.copy-to}" PARENT_SCOPE)
    endif()

  endforeach()
  set(${outs} ${${outs}} ${out} PARENT_SCOPE)
endfunction()

##### Download stuff
function(z_vcpkg_download_from_url data_prefix)
  z_vcpkg_convert_json_array_to_cmake_list(urls ${data_prefix}.urls)
  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")

  vcpkg_download_distfile(archive
    URLS "${urls}"
    FILENAME "${${data_prefix}.filename}"
    SHA512 "${${data_prefix}.sha512}"
  )

  vcpkg_extract_source_archive("${${data_prefix}.output-variable}"
      ARCHIVE "${archive}"
      PATCHES ${patches}
  )
  unset(archive)

  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_from_github data_prefix)
  set(opts "")
  if(${data_prefix}.host)
    list(APPEND opts GITHUB_HOST "${${data_prefix}.host}")
  endif()

  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")

  vcpkg_from_github(
      OUT_SOURCE_PATH "${${data_prefix}.output-variable}"
      REPO "${${data_prefix}.repository}"
      REF "${${data_prefix}.ref}"
      SHA512 "${${data_prefix}.sha512}"
      HEAD_REF "${${data_prefix}.head-ref}"
      PATCHES ${patches}
      ${opts}
  )
  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_from_gitlab data_prefix)
  set(opts "")
  if(${data_prefix}.host)
    list(APPEND opts GITLAB_URL "${${data_prefix}.host}")
  endif()

  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")

  vcpkg_from_gitlab(
    OUT_SOURCE_PATH "${${data_prefix}.output-variable}"
    REPO "${${data_prefix}.repository}"
    REF "${${data_prefix}.ref}"
    SHA512 "${${data_prefix}.sha512}"
    HEAD_REF "${${data_prefix}.head-ref}"
    PATCHES ${patches}
    ${opts}
  )
  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_from_bitbucket data_prefix)
  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")
  vcpkg_from_bitbucket(
      OUT_SOURCE_PATH "${${data_prefix}.output-variable}"
      REPO "${${data_prefix}.repository}"
      REF "${${data_prefix}.ref}"
      SHA512 "${${data_prefix}.sha512}"
      HEAD_REF "${${data_prefix}.head-ref}"
      PATCHES ${patches}
  )
  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_from_git data_prefix)
  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")
  vcpkg_from_git(
    OUT_SOURCE_PATH "${${data_prefix}.output-variable}"
    URL "${${data_prefix}.url}"
    REF "${${data_prefix}.ref}"
    #SHA512 "${${data_prefix}.sha512}"
    HEAD_REF "${${data_prefix}.head-ref}"
    PATCHES ${patches}
    # [LFS [<url>]]
  )
  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_download_from_sourceforge data_prefix)
  z_vcpkg_convert_json_array_to_cmake_list(patches "${data_prefix}.patches")
  vcpkg_from_sourceforge(
      OUT_SOURCE_PATH "${${data_prefix}.output-variable}"
      REPO "${${data_prefix}.repository}"
      REF "${${data_prefix}.ref}"
      SHA512 "${${data_prefix}.sha512}"
      #HEAD_REF "${${data_prefix}.head-ref}"
      PATCHES ${patches}
      FILENAME "${${data_prefix}.filename}"
      #[NO_REMOVE_ONE_LEVEL]
  )
  set("${${data_prefix}.output-variable}" "${${${data_prefix}.output-variable}}" PARENT_SCOPE)
endfunction()
##### JSON Parser

function(z_read_json_array out_vars json_data)
  set(out "")
  set(argn_list ${ARGN})
  list(JOIN argn_list "." argn_list_dot)

  string(JSON ${argn_list_dot}_length LENGTH "${json_data}" ${ARGN})
  set(${argn_list_dot}.size "${${argn_list_dot}_length}")
  list(APPEND out ${argn_list_dot}.size)
  set(${argn_list_dot}.index_list "")
  list(APPEND out ${argn_list_dot}.index_list)

  math(EXPR ${argn_list_dot}_length "${${argn_list_dot}_length}-1" OUTPUT_FORMAT DECIMAL)

  if(NOT ${argn_list_dot}_length LESS 0)
    foreach(${argn_list_dot}_index RANGE ${${argn_list_dot}_length})
      set(out_index "")
      z_read_json_member(out_index "${json_data}" ${ARGN} "${${argn_list_dot}_index}")
      list(APPEND out ${out_index})
      list(APPEND ${argn_list_dot}.index_list "${${argn_list_dot}_index}")
      unset(out_index)
    endforeach()
  endif()

  foreach(o IN LISTS out)
    set("${o}" "${${o}}" PARENT_SCOPE)
  endforeach()
  set("${out_vars}" ${out} PARENT_SCOPE)
endfunction()

function(z_read_json_obj out_vars json_data)
  set(out "")
  set(argn_list ${ARGN})
  list(JOIN argn_list "." argn_list_dot)

  string(JSON ${argn_list_dot}_length LENGTH "${json_data}" ${ARGN})
  set(${argn_list_dot}.size "${${argn_list_dot}_length}")
  list(APPEND out ${argn_list_dot}.size)
  set(${argn_list_dot}.members "")
  list(APPEND out ${argn_list_dot}.members)

  math(EXPR ${argn_list_dot}_length "${${argn_list_dot}_length}-1" OUTPUT_FORMAT DECIMAL)

  if(NOT ${argn_list_dot}_length LESS 0)
    foreach(${argn_list_dot}_index RANGE ${${argn_list_dot}_length})
      set(out_index "")
      string(JSON member_name MEMBER "${json_data}" ${ARGN} "${${argn_list_dot}_index}")
      z_read_json_member(out_index "${json_data}" ${ARGN} "${member_name}")
      list(APPEND out ${out_index})
      list(APPEND ${argn_list_dot}.members "${member_name}")
      unset(out_index)
      unset(member_name)
    endforeach()
  endif()
  foreach(o IN LISTS out)
    set("${o}" "${${o}}" PARENT_SCOPE)
  endforeach()
  set("${out_vars}" ${out} PARENT_SCOPE)
endfunction()

function(z_read_json_member out_vars json_data)
  set(out "")
  set(argn_list ${ARGN})
  message(STATUS "${ARGN}")
  list(JOIN argn_list "." argn_list_dot)
  string(JSON "z_${argn_list_dot}.json_type" TYPE "${json_data}" ${ARGN})

  if("${z_${argn_list_dot}.json_type}" MATCHES "^(NULL|NUMBER|STRING|BOOLEAN)$")
    string(JSON "${argn_list_dot}" GET "${json_data}" ${ARGN})
    # Cannot expand CMake variables here if you want output variables to be used in the same JSON file
    # string(CONFIGURE "${${argn_list_dot}}" "${argn_list_dot}" ESCAPE_QUOTES) 
    list(APPEND out "${argn_list_dot}")
  elseif("${z_${argn_list_dot}.json_type}" STREQUAL "ARRAY")
    set(array_out "")
    z_read_json_array(array_out "${json_data}" ${ARGN})
    list(APPEND out ${array_out})
    unset(array_out)
  elseif("${z_${argn_list_dot}.json_type}" STREQUAL "OBJECT")
    set(object_out "")
    z_read_json_obj(object_out "${json_data}" ${ARGN})
    list(APPEND out ${object_out})
    unset(object_out)
  else()
    message(FATAL_ERROR "Unknown json type found")
  endif()
  
  foreach(o IN LISTS out)
    set("${o}" "${${o}}" PARENT_SCOPE)
  endforeach()
  set("${out_vars}" ${out} PARENT_SCOPE)
endfunction()

function(z_vcpkg_convert_json_array_to_cmake_list var prefix)
  set(out "")
  foreach(item IN LISTS ${prefix}.index_list)
    list(APPEND out "${${prefix}.${item}}")
  endforeach()
  set("${var}" "${out}" PARENT_SCOPE)
endfunction()