# Find Python3 executable
vcpkg_find_acquire_program(PYTHON3)
set(VCPKG_PYTHON_EXECUTABLE "${PYTHON3}")
# Find Python3 libraries. Can't use find_package here, but we already know where everything is
file(GLOB VCPKG_PYTHON_INCLUDE "${CURRENT_INSTALLED_DIR}/include/python3.*")
set(VCPKG_PYTHON_LIBS_RELEASE "${CURRENT_INSTALLED_DIR}/lib")
set(VCPKG_PYTHON_LIBS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib")
string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" VCPKG_PYTHON_VERSION "${VCPKG_PYTHON_INCLUDE}")
