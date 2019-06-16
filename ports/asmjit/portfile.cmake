include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO asmjit/asmjit
  REF fc251c914e77cd079e58982cdab00a47539d7fc5
  SHA512 3db4ed97ded545994ab2e75df5bb027832c3b7adf44bdabfb89a98af4cc51f5e48d4a353b9e99f205702258dfcec70257d6d6c08db78cec941019b3f8a48232a
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


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()



# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/asmjit RENAME copyright)
