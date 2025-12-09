if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/cld3
  REF b48dc46512566f5a2d41118c8c1116c4f96dc661
  SHA512 c3650ffbf5855aaf04d03930f01c6efd76e1f2b2d47365348721f16531a14653ae5b3aff8fefa8e5fa1c769fdf1a9b441a88bc687f97f8c579b84f17c6984c9e
  HEAD_REF master
  PATCHES
      fix-build.patch
      unofficial-export.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-cld3Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-cld3")
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-cld3 PACKAGE_NAME unofficial-cld3)

file(GLOB PUBLIC_HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/*.h")
file(INSTALL ${PUBLIC_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/cld3")

file(GLOB HEADERS_SCRIPT_SPAN_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/src/script_span/*.h")
file(INSTALL ${HEADERS_SCRIPT_SPAN_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/cld3/script_span")

file(GLOB HEADERS_PROTO_FILES LIST_DIRECTORIES false "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cld_3/protos/*.h")
file(INSTALL ${HEADERS_PROTO_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/cld_3/protos")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
