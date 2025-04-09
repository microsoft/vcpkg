if(NOT DEFINED PYTHON_VERSION)
    message(FATAL_ERROR "PYTHON_VERSION should be defined.")
endif()

if(NOT DEFINED PYTHON_DIR)
    message(FATAL_ERROR "PYTHON_DIR should be defined.")
endif()

# We want to be able to import stuff from outside of this embeddable package.
# https://docs.python.org/3/library/sys_path_init.html#pth-files
string(REGEX MATCH "^3\\.[0-9]+" _python_version_plain "${PYTHON_VERSION}")
string(REPLACE "." "" _python_version_plain "${_python_version_plain}")
file(REMOVE "${PYTHON_DIR}/python${_python_version_plain}._pth")

# Since this embeddable package is not isolated anymore, we should make sure
# it doesn't accidentally pick up stuff from windows registry.
file(WRITE "${PYTHON_DIR}/sitecustomize.py" [[import os
import sys
sys.path.insert(1, os.path.dirname(os.path.realpath(__file__)))
]])
