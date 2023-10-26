if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/idk
  REF 5413729fefcba89faf410e76cfa9cff54d488079
  SHA512 02632a7c91d691251791dbcf1828c54ff4b7510c1f00c4985a1f7f0fe10a949bef6ea57907d4508e1e79f45d05ca0985f49ca0841448c9724a0a5a1038bdd4bb
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
