vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 761130b1d8f32b5d3d612d285664fcfef5258149
  SHA512 a86fd58ba0c8bc81ec575e86a9acdf4a11f2acc9c2facd2a0a8512cffa9ee6fc0bd877a1f33fb52f8f510eff1de654b45cd4f5f5a18c5252ecae22a92db6e93e
  HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASMJIT_STATIC=1
  )
else()
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
  )
endif()

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
