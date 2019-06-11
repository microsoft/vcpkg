include(vcpkg_common_functions)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nagzira/xmsh
  REF v0.5.2
  SHA512 f4b722e74679223f5329802ff5dd6a0ade9781246227525303a5382b744e3763aca794a49146867ef5053f06ec956a69dac06469c315bb1388fea88b3ef5c0db
  HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYPATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYPATH}")

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DPYTHON3_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
