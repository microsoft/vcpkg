# Give the CMake module a little bit of help to find the debug libraries
find_library(PostgreSQL_LIBRARY_DEBUG
NAMES pq
PATHS
  "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"
NO_DEFAULT_PATH
)
_find_package(${ARGS})