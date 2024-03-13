include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/../python3/vcpkg-port-config.cmake")

set(VCPKG_PYTHON3_BASEDIR "${CURRENT_INSTALLED_DIR}/tools/python3")
set(VCPKG_PYTHON3_SCRIPTS "tools/python3")
if(VCPKG_TARGET_IS_WINODWS)
  string(APPEND VCPKG_PYTHON3_SCRIPTS "/Scripts")
endif()
find_program(VCPKG_PYTHON3 NAMES python${PYTHON3_VERSION_MAJOR}.${PYTHON3_VERSION_MINOR} python${PYTHON3_VERSION_MAJOR} python PATHS "${VCPKG_PYTHON3_BASEDIR}" NO_DEFAULT_PATH)

include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_python_functions.cmake")
