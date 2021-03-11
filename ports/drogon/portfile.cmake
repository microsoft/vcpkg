vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  an-tao/drogon
  REF
  v1.4.1
  SHA512
  8611c18e65229095f5443f10c87e91593d619bc3a2d47da6d19d501a64be1aba12a813e44ccfc1c10179e5b0fa10121e8806955c0091258992501b88fa50d939
  HEAD_REF
  master
  PATCHES
  vcpkg.patch
  resolv.patch)

vcpkg_configure_cmake(SOURCE_PATH
                      ${SOURCE_PATH}
                      PREFER_NINJA
                      OPTIONS
                      -DBUILD_EXAMPLES=OFF)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Drogon)
# Copy drogon_ctl
vcpkg_copy_tools(TOOL_NAMES drogon_ctl AUTO_CLEAN)

# # Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin"
       "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()
