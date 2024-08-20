if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

if(VCPKG_TARGET_IS_UWP)
  list(APPEND PATCH_FILES fix-uwp-linkage.patch)
  # Inject linker option using the `LINK` environment variable
  # https://docs.microsoft.com/en-us/cpp/build/reference/linker-options
  # https://docs.microsoft.com/en-us/cpp/build/reference/linking#link-environment-variables
  set(ENV{LINK} "/APPCONTAINER")
endif()

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
  list(APPEND PATCH_FILES use-md.patch)
else()
  list(APPEND PATCH_FILES use-mt.patch)
endif()

vcpkg_from_sourceforge(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO pthreads4w
  FILENAME "pthreads4w-code-v${VERSION}.zip"
  SHA512 49e541b66c26ddaf812edb07b61d0553e2a5816ab002edc53a38a897db8ada6d0a096c98a9af73a8f40c94283df53094f76b429b09ac49862465d8697ed20013
  PATCHES
    fix-arm-macro.patch
    fix-arm64-version_rc.patch # https://sourceforge.net/p/pthreads4w/code/merge-requests/6/
    fix-pthread_getname_np.patch
    fix-install.patch
    whitespace_in_path.patch
    ${PATCH_FILES}
)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" DESTROOT_DEBUG)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" DESTROOT_RELEASE)

vcpkg_list(SET OPTIONS_DEBUG "DESTROOT=${DESTROOT_DEBUG}")
vcpkg_list(SET OPTIONS_RELEASE "DESTROOT=${DESTROOT_RELEASE}" "BUILD_RELEASE=1")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_list(APPEND OPTIONS_DEBUG "BUILD_STATIC=1")
  vcpkg_list(APPEND OPTIONS_RELEASE "BUILD_STATIC=1")
endif()

vcpkg_install_nmake(
  CL_LANGUAGE C
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_NAME Makefile
  OPTIONS_DEBUG ${OPTIONS_DEBUG}
  OPTIONS_RELEASE ${OPTIONS_RELEASE}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/PThreads4WConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads4W")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthread.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthread" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthreads" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads-windows.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads_windows" RENAME vcpkg-cmake-wrapper.cmake)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
