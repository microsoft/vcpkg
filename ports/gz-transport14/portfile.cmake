set(PACKAGE_NAME transport)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 988d546044ab05efb1cd14c5dbd035e040a0a8cad631c99a330420676f882a16e9d6c2b23363b1e82e162fb2baa4f0a01eff84d1f1be0f6e92d69d0e168867a7
   OPTIONS 
   PATCHES
      uuid-osx.patch
)
