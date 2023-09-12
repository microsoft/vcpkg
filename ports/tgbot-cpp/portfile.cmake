vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.6
  SHA512 c7dd9efb1b0edfe34de06205ed26ad076d0e61a48be22df440290478ab55917c7d926af0ea7d1c76b82b5859f4f2454217feb6dc5b7c7680e6f6177f063242a0
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)
