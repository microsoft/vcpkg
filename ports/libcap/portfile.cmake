vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git://git.kernel.org/pub/scm/libs/libcap/libcap.git
  FETCH_REF "libcap-${VERSION}"
  REF 3c7dda330bd9a154bb5b878d31fd591e4951fe17
  PATCHES
    configure.patch
    cross-compile.patch
)

# SKIP_CONFIGURE is broken https://github.com/microsoft/vcpkg/issues/14389
# so we use patch to create empty configure executable

vcpkg_configure_make(
  SOURCE_PATH "${SOURCE_PATH}"
  COPY_SOURCE
)

vcpkg_build_make(SUBPATH libcap
  BUILD_TARGET cap_names.h
  OPTIONS
    prefix=${CURRENT_INSTALLED_DIR}
    CC=gcc # use host architecture to generate cap_names.h
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_build_make(SUBPATH libcap
    BUILD_TARGET libcap.a
    OPTIONS
      prefix=${CURRENT_INSTALLED_DIR}
  )
else()
  vcpkg_build_make(SUBPATH libcap
    BUILD_TARGET libcap.so
    OPTIONS
      prefix=${CURRENT_INSTALLED_DIR}
  )
endif()

vcpkg_build_make(SUBPATH libcap
  BUILD_TARGET libcap.pc
  OPTIONS
    prefix=${CURRENT_INSTALLED_DIR}
)

file(INSTALL "${SOURCE_PATH}/libcap/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

set(BUILD_DIR_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_RELEASE}/libcap/libcap.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
  file(INSTALL "${BUILD_DIR_RELEASE}/libcap/libcap.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" FOLLOW_SYMLINK_CHAIN)
endif()

set(BUILD_DIR_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_DEBUG}/libcap/libcap.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
  file(INSTALL "${BUILD_DIR_DEBUG}/libcap/libcap.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" FOLLOW_SYMLINK_CHAIN)
endif()

file(INSTALL "${BUILD_DIR_RELEASE}/libcap/libcap.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(INSTALL "${BUILD_DIR_DEBUG}/libcap/libcap.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

vcpkg_fixup_pkgconfig()
