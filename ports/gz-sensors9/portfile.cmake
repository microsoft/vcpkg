set(PACKAGE_NAME sensors)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 237235ecc5000e2785e293f7aad65cb72690e46ba06ca6649add9a8baa24e0f7777e21f59fa0a254a4a853fa8f172cc4e9e58770e227bb9b6797949bd8bc06f6
   OPTIONS 
   PATCHES
)
