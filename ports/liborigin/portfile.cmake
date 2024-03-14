vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liborigin
    REF liborigin/3.0
    FILENAME liborigin-${VERSION}.tar.gz
    SHA512 9fb5ae6d8aa8fb54e659482f8f5dc581b8d0ace2ebca7bb9f092b7ec753049d497491eb47ad89b12c8ddf7e19dc47f76e76c51ace789366370bd056d99e091ee
    PATCHES
        fix-installing-import-library-with-MSVC.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(LIB_OPTION "-DBUILD_STATIC_LIBS=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${LIB_OPTION}
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
  file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe" "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
  file(REMOVE_RECURSE ${EXES})
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
