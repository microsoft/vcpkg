include_guard(GLOBAL)
include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python/vcpkg-port-config.cmake")

function(vcpkg_python_test_import)
  cmake_parse_arguments(
    PARSE_ARGV 0
    "arg"
    ""
    "MODULE;PYTHON_EXECUTABLE"
    "MODULES;DLL_SEARCH_PATHS"
  )

  if(VCPKG_CROSSCOMPILING OR (VCPKG_CRT_LINKAGE STREQUAL "static" AND NOT arg_PYTHON_EXECUTABLE))
    return()
  endif()

  if(NOT arg_PYTHON_EXECUTABLE AND COMMAND vcpkg_get_vcpkg_installed_python)
    vcpkg_get_vcpkg_installed_python(arg_PYTHON_EXECUTABLE)
  elseif(NOT DEFINED arg_PYTHON_EXECUTABLE)
    message(FATAL_ERROR "arg_PYTHON_EXECUTABLE is not defined and command vcpkg_get_vcpkg_installed_python is not available!")
  endif()

  if(arg_MODULE)
    list(APPEND arg_MODULES "${arg_MODULE}")
  endif()

  list(APPEND arg_DLL_SEARCH_PATHS "${CURRENT_INSTALLED_DIR}/bin")

  set(PYTHON_DLL_SEARCH_DIRS "")
  foreach(dll_path IN LISTS arg_DLL_SEARCH_PATHS)
    if(NOT EXISTS "${dll_path}")
      message(FATAL_ERROR "Path '${dll_path}' in DLL_SEARCH_PATHS does not exist!")
    endif()
    string(APPEND PYTHON_DLL_SEARCH_DIRS "  os.add_dll_directory('${dll_path}')\n")
  endforeach()

  set(PYTHON_IMPORTS "")
  foreach(module IN LISTS arg_MODULES)
    string(APPEND PYTHON_IMPORTS "from ${module} import *\n")
  endforeach()

  unset(pythonpath_bak)
  if(DEFINED ENV{PYTHONPATH})
    set(pythonpath_bak "$ENV{PYTHONPATH}")
  endif()

  set(ENV{PYTHONPATH} "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")

  message(STATUS "Testing import of python module '${arg_MODULES}' ...")

  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/import_test.py.in" "${CURRENT_BUILDTREES_DIR}/import_test.py" @ONLY)

  vcpkg_execute_required_process(COMMAND "${arg_PYTHON_EXECUTABLE}" "${CURRENT_BUILDTREES_DIR}/import_test.py"
    LOGNAME "python-import-${arg_MODULE}-${TARGET_TRIPLET}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
  )
  message(STATUS "Import of '${arg_MODULES}' successful")

  if(DEFINED pythonpath_bak)
    set(ENV{PYTHONPATH} "${pythonpath_bak}")
  else()
    unset(ENV{PYTHONPATH})
  endif()
endfunction()
