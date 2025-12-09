include_guard(GLOBAL)

function(vcpkg_get_vcpkg_installed_python out_python)
  cmake_parse_arguments(PARSE_ARGV 1 "arg" "INTERPRETER" "" "")
  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT VCPKG_TARGET_IS_WINDOWS)
    # vcpkg installed python on !windows works as normal python would work.
    set(${out_python} "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python3" PARENT_SCOPE)
    return()
  endif()
  if(DEFINED CACHE{z_vcpkg_get_vcpkg_installed_python})
    set(${out_python} "${z_vcpkg_get_vcpkg_installed_python}" PARENT_SCOPE)
    return()
  elseif(arg_INTERPRETER AND DEFINED CACHE{z_vcpkg_get_vcpkg_installed_python_interpreter})
    set(${out_python} "${z_vcpkg_get_vcpkg_installed_python_interpreter}" PARENT_SCOPE)
    return()
  endif()

  # On windows python is unable to lookup DLLs, so a manual venv is created
  set(python_home "${CURRENT_HOST_INSTALLED_DIR}/tools/python3")
  set(python_base "${CURRENT_BUILDTREES_DIR}/python-${TARGET_TRIPLET}")

  file(GLOB python_files LIST_DIRECTORIES false "${python_home}/*")
  if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/DLLs")
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/DLLs/" DESTINATION "${python_base}/DLLs")
  endif()
  file(COPY ${python_files} DESTINATION "${python_base}/Scripts")
  file(MAKE_DIRECTORY "${python_base}/Lib/site-packages")

  file(WRITE "${python_base}/pyvenv.cfg"
"
home = ${python_home}
include-system-site-packages = false
version = ${PYTHON3_VERSION}
executable = ${python_home}/python.exe
command = ${python_home}/python.exe -m venv ${python_base}
"
)

  file(WRITE "${python_base}/Lib/site-packages/sitecustomize.py"
"
import os
import sys
from pathlib import Path

import site
#enable direct lookup of installed site-packages without the need to copy them
site.addsitedir(sys.base_prefix + '/Lib/site-packages')

vcpkg_bin_path = Path(sys.base_prefix + '/../../bin')
if vcpkg_bin_path.is_dir():
  os.add_dll_directory(vcpkg_bin_path)
"
)

  # This part is intentionally copies headers and link libraries from the target
  # installation (CURRENT_INSTALLED_DIR): The function provides infrastructure for
  # building extensions for the target python while running the host python interpreter.
  # The calling port is responsible to provided the target python3 dependency.
  # However, it is possible to use just the interpreter,
  # e.g. for running extensions already installed in the host triplet.
  if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/python${PYTHON3_VERSION_MAJOR}${PYTHON3_VERSION_MINOR}.lib")
    file(COPY "${CURRENT_INSTALLED_DIR}/${PYTHON3_INCLUDE}/" DESTINATION "${python_base}/include")
    set(suffix "PCBuild/AMD64") # TODO: ask python for the correct suffix.
    file(COPY "${CURRENT_INSTALLED_DIR}/lib/python${PYTHON3_VERSION_MAJOR}${PYTHON3_VERSION_MINOR}.lib" DESTINATION "${python_base}/${suffix}")
    set(z_vcpkg_get_vcpkg_installed_python "${python_base}/Scripts/python.exe" CACHE INTERNAL "")
  elseif(arg_INTERPRETER)
    set(z_vcpkg_get_vcpkg_installed_python_interpreter "${python_base}/Scripts/python.exe" CACHE INTERNAL "")
  else()
    message(${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}
      "Target python3 installation was not found, and the INTERPRETER wasn't given."
      " Either add a \"python3\" dependency to ${PORT},"
      " or add 'INTERPRETER' to the '${CMAKE_CURRENT_FUNCTION}' call."
    )
  endif()

  set(${out_python} "${python_base}/Scripts/python.exe" PARENT_SCOPE)
endfunction()
