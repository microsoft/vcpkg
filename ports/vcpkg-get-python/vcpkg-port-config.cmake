function(vcpkg_get_vcpkg_installed_python out_python)
  if(NOT VCPKG_TARGET_IS_WINDOWS)
    # vcpkg installed python on !windows works as normal python would work.
    set(${out_python} "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python3" PARENT_SCOPE)
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

 set(${out_python} "${python_base}/Scripts/python.exe" PARENT_SCOPE)
endfunction()
