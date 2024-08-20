set(PACKAGE_NAME msgs)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 669e60fc35868e4d86695104a58aecaef9ad08861cba97ff91c7306caf66ec237da46c0a13f5f59907371fc7a4dd56d5506fabe4ba97c393889fc5a9c2a101ee
   OPTIONS 
   PATCHES
      remove_ruby.patch
)
