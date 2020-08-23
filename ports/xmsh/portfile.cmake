vcpkg_find_acquire_program(PYTHON3)

vcpkg_fail_port_install(ON_TARGET "Windows")
message("Building with a gcc version less than 7.1.0 is not supported.")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libxmsh/xmsh
    REF  e1900845b796ef977db70519b2ac08eebd788236
    SHA512 643c6c94956de9b6fae635b6528e8ba756f4a2bc38de71613c2dd8d47f4a043aee7b6e7fec1870b306be3bea9f5c0c81d1d343bfc27883b3fba986fbc5b15406
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DPYTHON3_EXECUTABLE=${PYTHON3}
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYPATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYPATH}")

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/copyright.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
