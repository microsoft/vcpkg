string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE "${PORT}")
set(PACKAGE_NAME "${CMAKE_MATCH_1}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME "${PACKAGE_NAME}"
   REF "${PORT}${VERSION_MAJOR}_${VERSION}"
   VERSION "${VERSION}"
   SHA512 e6017537f2cc9ea76b3b577231e9819e58e8c463db1994da9483ac4e3c4c88e8ef503d7159e42b64519d988c4e20c37d4e76587e9a948feebc4b12ed41e0d68b
   OPTIONS 
   PATCHES
      remove_docs.patch
)
