# Define a function to check if a file type of Mach-O
# 0: not a Mach-O file
# 1: shared library
# 2: executable 
function(z_vcpkg_get_mach_o out_var)
  cmake_parse_arguments(PARSE_ARGV 1 arg "" "FILE" "")

  if(NOT EXISTS "${arg_FILE}")
    message(FATAL_ERROR "File ${arg_FILE} does not exist.")
  endif()

  find_program(
    file_cmd
    NAMES file
    DOC "Absolute path of file cmd"
    REQUIRED
  )

  execute_process(
    COMMAND "${file_cmd}" "${arg_FILE}"
    OUTPUT_VARIABLE get_file_type_ov
    RESULT_VARIABLE get_file_type_rv
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  message(DEBUG "${get_file_type_ov}")

  # Check if the file is a Mach-O file
  if("${get_file_type_ov}" MATCHES ".*Mach-O.*.shared library.*")
    set(${out_var} 1 PARENT_SCOPE)
  elseif("${get_file_type_ov}" MATCHES ".*Mach-O.*.executable.*")
    set(${out_var} 2 PARENT_SCOPE)
  else()
    set(${out_var} 0 PARENT_SCOPE)
  endif()
endfunction()


# Define a function to get the rpath list of a Mach-O file
function(z_vcpkg_get_rpaths out_var)
  cmake_parse_arguments(PARSE_ARGV 1 arg "" "FILE" "")

  if(NOT EXISTS "${arg_FILE}")
    message(FATAL_ERROR "File ${arg_FILE} does not exist.")
  endif()

  find_program(
    otool_cmd
    NAMES otool
    DOC "Absolute path of otool cmd"
    REQUIRED
  )

  execute_process(
    COMMAND "${otool_cmd}" -l "${arg_FILE}"
    OUTPUT_VARIABLE get_rpath_ov
    RESULT_VARIABLE get_rpath_rv
  )

  message(DEBUG "${get_rpath_ov}")

  # Check if the otool command executed successfully
  if(get_rpath_rv EQUAL 0)
    # Extract the LC_RPATH load commands and extract the paths
    string(REGEX REPLACE "[^\n]+cmd LC_RPATH\n[^\n]+\n[^\n]+path ([^\n]+) \\(offset[^\n]+\n" "rpath \\1\n" get_rpath_ov "${get_rpath_ov}")
    string(REGEX MATCHALL "rpath [^\n]+" get_rpath_ov "${get_rpath_ov}")
    string(REGEX REPLACE "rpath " "" rpath_list "${get_rpath_ov}")
  
    set("${out_var}" "${rpath_list}" PARENT_SCOPE)
  else()
    message(WARNING "otool -l ${arg_FILE}, failed: ${get_rpath_ov}")
  endif()
endfunction()


# Define a function to delete the rpath list from a Mach-O file
function(z_vcpkg_delete_rpaths)
  cmake_parse_arguments(PARSE_ARGV 0 arg "" "FILE" "")

  if(NOT EXISTS "${arg_FILE}")
    message(FATAL_ERROR "File ${arg_FILE} does not exist.")
  endif()

  z_vcpkg_get_rpaths(rpath_list FILE "${arg_FILE}")
  message(DEBUG "READY to delete rpath_list: ${rpath_list}")

  find_program(
    install_name_tool_cmd
    NAMES install_name_tool
    DOC "Absolute path of install_name_tool cmd"
    REQUIRED
  )

  # Iterate over the runpaths and delete them from the file
  foreach(rpath IN LISTS rpath_list)
    execute_process(
      COMMAND "${install_name_tool_cmd}" -delete_rpath "${rpath}" "${arg_FILE}"
      OUTPUT_VARIABLE del_rpath_ov
      RESULT_VARIABLE del_rpath_rv
    )

    if(del_rpath_rv EQUAL 0)
      message(DEBUG "delete rpath: ${rpath},\n ${del_rpath_ov}")
    else()
      message(WARNING "install_name_tool -delete_rpath ${rpath} ${arg_FILE}, failed: \n${del_rpath_ov}")
    endif()
  endforeach()
endfunction()

# Define a function to get the install name of a Mach-O file
function(z_vcpkg_get_install_name out_var)
  cmake_parse_arguments(PARSE_ARGV 1 arg "" "FILE" "")

  if(NOT EXISTS "${arg_FILE}")
    message(FATAL_ERROR "File ${arg_FILE} does not exist.")
  endif()

  find_program(
    otool_cmd
    NAMES otool
    DOC "Absolute path of otool cmd"
    REQUIRED
  )

  execute_process(
    COMMAND "${otool_cmd}" -D "${arg_FILE}"
    OUTPUT_VARIABLE get_install_name_ov
    RESULT_VARIABLE get_install_name_rv
  )

  message(DEBUG "${get_install_name_ov}")

  if(get_install_name_rv EQUAL 0)
    # Extract the second line containing the install name
    string(REGEX MATCH "^[^\n]*\n([^\n]*)" MATCHED_LINES "${get_install_name_ov}")
    set("${out_var}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
  else()
    message(WARNING "otool -D ${arg_FILE}, failed: \n${get_install_name_ov}")
  endif()
endfunction()

# Define a function to get the dependent shared library install names of a Mach-O file
function(z_vcpkg_get_dep_install_names out_var)
  cmake_parse_arguments(PARSE_ARGV 1 arg "" "FILE" "")

  if(NOT EXISTS "${arg_FILE}")
    message(FATAL_ERROR "File ${arg_FILE} does not exist.")
  endif()

  # Find the absolute path of the otool command
  find_program(
    otool_cmd
    NAMES otool
    DOC "Absolute path of otool cmd"
    REQUIRED
  )
  
  # Execute the otool command to get the dependent library load commands
  execute_process(
    COMMAND "${otool_cmd}" -L "${arg_FILE}"
    OUTPUT_VARIABLE get_dep_install_names_ov
    RESULT_VARIABLE get_dep_install_names_rv
  )

  message(DEBUG "${get_dep_install_names_ov}")

  # Check if the otool command executed successfully
  if(get_dep_install_names_rv EQUAL 0)
    # Strip the first line
    string(REGEX REPLACE "^.*:\n" "" get_dep_install_names_ov "${get_dep_install_names_ov}")
    # Extract the install names of the dependencies
    string(REGEX MATCHALL "[^\n\t]+(.dylib|.so)" dependencies "${get_dep_install_names_ov}")

    z_vcpkg_get_mach_o(type FILE "${arg_FILE}")
    if(type EQUAL 1)
      list(LENGTH dependencies n)
      math(EXPR n "${n}-1")
      list(SUBLIST dependencies 1 ${n} dependencies)
    endif()

    set("${out_var}" "${dependencies}" PARENT_SCOPE)
  else()
    message(WARNING "otool -L ${arg_FILE}, failed: \n${get_dep_install_names_ov}")
  endif()
endfunction()

# Define a function to fix the install names and rpaths in Mach-O files in package dir
# A common package dir stucture:
# /opt/vcpkg/packages/icu_arm64-osx-dynamic/
# ├── debug
# │  └── lib
# │       ├── libicudata.72.1.dylib
# │       ├── libicudata.72.dylib -> libicudata.72.1.dylib
# │       ├── libicudata.dylib -> libicudata.72.1.dylib
# │       ├── ...
# │       └── pkgconfig
# ├── include
# │   └── unicode
# │       ├── alphaindex.h
# │       ├── ...
# │       └── vtzone.h
# ├── lib
# │   ├── libicudata.72.1.dylib
# │   ├── libicudata.72.dylib -> libicudata.72.1.dylib
# │   ├── libicudata.dylib -> libicudata.72.1.dylib
# │   ├── ...
# │   └── pkgconfig
# │       ├── ...
# │       └── icu-uc.pc
# ├── share
# │   └── icu
# └── tools
#     └── icu
#         └── bin
#             └── derb 
# Here, it'wll do fix:
# 1. for shared libraries in `lib` and `debug/lib`
#    - fix its own install names to `@rpath` prefix 
#    - fix its dependent shared library install name to `@rpath` prefix
#       - include libraries only from the same port, assuming other libraries from other managed ports by vcpkg are already fixed!
#       - exclude system libraries in `/usr/lib/` and `/System/Library`!
#    - fix rpath to `@loader`(or using absolute path `CURRENT_INSTALLED_DIR`, like `/opt/vcpkg/installed/arm64-osx-dynamic/lib` or `/opt/vcpkg/installed/arm64-osx-dynamic/debug/lib`)
# 2. for exe in `tools/{package}/bin/`
#    - fix its dependent shared library install name to `@rpath` prefix
#       - include libraries only from the same port in lib/, assuming other libraries from other managed ports by vcpkg are already fixed!
#       - exclude system libraries in `/usr/lib/` and `/System/Library`!
#    - fix rpath to `@loader/../../../`  to be relative with `lib/`
function(z_vcpkg_fixup_install_name_rpath_in_dir)
  find_program(
    install_name_tool_cmd
    NAMES install_name_tool
    DOC "Absolute path of install_name_tool cmd"
    REQUIRED
  )

  find_program(
    otool_cmd
    NAMES otool
    DOC "Absolute path of otool cmd"
    REQUIRED
  )

  message(DEBUG "Start fix install name and rpath for Mach-O files")

  # Iterate over the folders. DON'T change order!
  foreach(subfolder IN ITEMS lib debug/lib tools)
    set(folder "${CURRENT_PACKAGES_DIR}/${subfolder}")

    if(NOT EXISTS "${folder}")
      continue()
    endif()

    get_filename_component(folder_name "${folder}" NAME)

    # Get all files in the folder
    file(GLOB_RECURSE files LIST_DIRECTORIES FALSE "${folder}/*")

    set(fix_files)
    # 1. Fix install name and rpath
    foreach(file IN LISTS files)
      # Check if the file is a Mach-O file
      z_vcpkg_get_mach_o(type FILE "${file}")
      if(type EQUAL 0)
        continue()
      endif()

      # Skip if the file is a symlink
      if(IS_SYMLINK "${file}")
        continue()
      endif()

      message(DEBUG "Start to fix mach-O file install_name and rpath: ${file}")

      # Get the directory of the file
      get_filename_component(file_dir "${file}" DIRECTORY)
      # Get the base name of the file
      get_filename_component(filename "${file}" NAME)

      # Get the major version
      string(REGEX REPLACE "(lib[^\\.]+\\.[0-9]+).*\\.(dylib|so)" "\\1.\\2" filename_major "${filename}")
      set(install_name_file "${file_dir}/${filename_major}")

      # Try the major version file
      if(NOT EXISTS "${install_name_file}" OR IS_SYMLINK "${install_name_file}")
        # Get the major.minor version if major version file is missing
        string(REGEX REPLACE "(lib[^\\.]+\\.[0-9]+.[0-9]+).*\\.(dylib|so)" "\\1.\\2" filename_major_minor "${filename}")
        set(install_name_file "${file_dir}/${filename_major_minor}")

        # Fall back to the file name itself if the major.minor version file is missing or is a symlink
        if(NOT EXISTS "${install_name_file}" OR IS_SYMLINK "${install_name_file}")
          set(install_name_file "${file}")
        endif()
      endif()

      # Compute the path relative to 'lib'
      if(type EQUAL 2)
        file(RELATIVE_PATH relative_to_lib "${file_dir}" "${CURRENT_PACKAGES_DIR}/lib")
        file(RELATIVE_PATH relative_filename_to_lib  "${CURRENT_PACKAGES_DIR}/lib" "${file}")
      else()
        file(RELATIVE_PATH relative_to_lib "${file_dir}" "${folder}")
        file(RELATIVE_PATH relative_filename_to_lib "${folder}" "${install_name_file}")
      endif()

      # Set the rpath and id_name based on the relative paths
      if(relative_to_lib STREQUAL "")
        set(rpath "@loader_path")
        set(id_name "@rpath/${relative_filename_to_lib}")
      else()
        set(rpath "@loader_path/${relative_to_lib}")
        set(id_name "@rpath/${relative_filename_to_lib}")
      endif()

      # Delete existing runpaths from the file
      z_vcpkg_delete_rpaths(FILE "${file}")

      # 1.1 Fix the install name of the file. If this fails, the file is not a Mach-O file
      # TODO: Should skip this if the Mach-O file has already `@rpath` prefix install name?
      if(type EQUAL 1)
        execute_process(
          COMMAND "${install_name_tool_cmd}" -id "${id_name}" "${file}"
          OUTPUT_VARIABLE set_install_name_ov
          RESULT_VARIABLE set_install_name_rv 
        )
  
        if(NOT set_install_name_rv EQUAL 0)
          message(FATAL_ERROR "Failed, install_name_tool -id ${id_name} ${file}, \n${set_install_name_ov}")
          continue()
        endif()
      endif()

      message(DEBUG "Fixed install name: ${file} (${id_name})")

      # 1.2 Add the rpath to the file
      execute_process(
        COMMAND "${install_name_tool_cmd}" -add_rpath "${rpath}" "${file}"
        OUTPUT_VARIABLE set_rpath_ov
        RESULT_VARIABLE set_rpath_rv
      )

      if(NOT set_rpath_rv EQUAL 0)
        message(FATAL_ERROR "Failed, install_name_tool -add_rpath ${rpath} ${file}, \n${set_rpath_ov}")
        continue()
      endif()

      message(DEBUG "Fixed rpath: ${file} (${rpath})")

      list(APPEND fix_files "${file}")
    endforeach()

    message(DEBUG "All found fix files in ${folder}:\n ${fix_files}")

    # 2. Fix the dependent shared libraries install name
    foreach(file IN LISTS fix_files)
      message(DEBUG "Start to fix mach-O file dep install names: ${file}")

      z_vcpkg_get_mach_o(type FILE "${file}")

      # Get the dependent install names of the current file
      z_vcpkg_get_dep_install_names(dep_install_names FILE "${file}")
      message(DEBUG "Before Fix ${file} dependencies: ${dep_install_names}")

      # Filter out dependencies located in '/usr/lib/*.dylib' and '/System/Library'
      list(FILTER dep_install_names EXCLUDE REGEX "^/usr/lib/.*(dylib|so)$")
      list(FILTER dep_install_names EXCLUDE REGEX "^/System/Library/.*(dylib|so)$")

      # Iterate over the filtered dependencies and fix their install names
      foreach(orig_dep_install_name IN LISTS dep_install_names)
        string(REGEX MATCH "[^/]+(.dylib|.so)" dep_install_name "${orig_dep_install_name}")
	message(DEBUG "dep_install_name: ${dep_install_name} (${orig_dep_install_name})")
                
        if(type EQUAL 2)
          file(GLOB_RECURSE dep_files LIST_DIRECTORIES FALSE "${CURRENT_PACKAGES_DIR}/lib/${dep_install_name}")
        else()
          file(GLOB_RECURSE dep_files LIST_DIRECTORIES FALSE "${folder}/${dep_install_name}")
        endif()

        if(NOT dep_files)
          message(DEBUG "No dep files found.")
          continue()
        endif()

        foreach(dep_file IN LISTS dep_files)
          message(DEBUG "dep file: ${dep_file}")

          z_vcpkg_get_install_name(id_name FILE "${dep_file}")
          message(DEBUG "${dep_install_name} match with ${dep_file} of install name ${id_name}")

          execute_process(
            COMMAND "${install_name_tool_cmd}" -change "${orig_dep_install_name}" "${id_name}" "${file}"
            OUTPUT_VARIABLE change_dep_install_name_ov
            RESULT_VARIABLE change_dep_install_name_rv
          )
          
          if(NOT change_dep_install_name_rv EQUAL 0)
            message(FATAL_ERROR "Failed, install_name_tool -change ${dep_install_name} ${id_name} ${file}, \n${change_dep_install_name_ov}")
            continue()
          else()
            message(DEBUG "Fix ${file}: ${dep_install_name} to ${id_name}")
            break()
          endif()
        endforeach()
      endforeach()

      z_vcpkg_get_dep_install_names(dep_files FILE "${file}")
      message(DEBUG "After Fix dependencies: ${dep_files}")

    endforeach()
  endforeach()
endfunction()

z_vcpkg_fixup_install_name_rpath_in_dir()
