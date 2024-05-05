vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO snap7
    REF "${VERSION}"
    FILENAME "snap7-full-${VERSION}.7z"
    SHA512 84F4E1AD15BFEC201F9EB1EC90A28F37DFC848E370DB5CEA22EF4946F41FF6CC514581D29D592B57EE6D4C77F4AABB4B2BBA1E3637043161821BA2FFAE7F2DD6
    PATCHES 
      0001-remove-using-namespace-std.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/src")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/src"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/snap7/__history")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lgpl-3.0.txt")
