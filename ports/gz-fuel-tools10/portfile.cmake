set(PACKAGE_NAME fuel-tools)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 a87bb313c17c9624e49cdf39399f90630256155fc410518aa03b340cc0b26e8955fa2d72623974aa4b474c270a25451989a293aaa015b43642f1018aeff8fdd4
   OPTIONS 
   PATCHES
      remove_docs.patch
)
