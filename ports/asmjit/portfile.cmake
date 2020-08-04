vcpkg_fail_port_install(ON_ARCH "arm")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF 80645e66a8ae85749937bda3b329388c8a76ea4c
  SHA512 8e7b0aed14e8ce05e6e6b2eed77be23a81b9548a146aef187ac6beced3bc2a6cba92835718adb901a1ab983fab32f3e9f18061b157b2276bb1451a71ca1195b8
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
