vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm64")

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Z3Prover/z3
  REF 78ed71b8de7d4d089f2799bf2d06f411ac6b9062 # z3-4.8.6
  SHA512 3505a2e3c634ea5369456b857665d9de538be631f7ce9b2eb84ef318081bffb286186abc98f7bcbf615c0396081aebc65ebc5f20135cd2b97c5228452550ffa4
  HEAD_REF master
  PATCHES
         fix-install-path.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(BUILD_STATIC "-DBUILD_LIBZ3_SHARED=OFF")
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    ${BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/z3 TARGET_PATH share/Z3)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
