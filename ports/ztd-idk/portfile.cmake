if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/idk
  REF 00c82f4fd3b119ace0ea5e654945e9b7f3fd0b20 
  SHA512 14c33d97ef45da3f5f4d7064ed9de7e89a03b10d0537ee54c11b456561845e52cf95d034ef951e51d3eeb96e9d4b8db0175fa5ef59d8bb53bcc01fe3935742aa
  HEAD_REF main
  PATCHES fix-cmake-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
