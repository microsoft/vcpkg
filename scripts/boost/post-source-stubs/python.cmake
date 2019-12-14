# Find Python. Can't use find_package here, but we already know where everything is
set(PYTHON_DIR_NAME "python3\.*")
file(GLOB PYTHON_INCLUDE_PATH "${CURRENT_INSTALLED_DIR}/include/${PYTHON_DIR_NAME}")
set(PYTHONLIBS_RELEASE "${CURRENT_INSTALLED_DIR}/lib")
set(PYTHONLIBS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib")
string(REGEX REPLACE ".*python([0-9\.]+)$" "\\1" PYTHON_VERSION "${PYTHON_INCLUDE_PATH}")
