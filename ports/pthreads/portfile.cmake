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

list(APPEND PATCH_FILES fix-pthread_getname_np.patch fix-install.patch)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pthreads4w
    FILENAME "pthreads4w-code-v${VERSION}.zip"
    SHA512 49e541b66c26ddaf812edb07b61d0553e2a5816ab002edc53a38a897db8ada6d0a096c98a9af73a8f40c94283df53094f76b429b09ac49862465d8697ed20013
    PATCHES
        fix-arm-macro.patch
        fix-arm64-version_rc.patch # https://sourceforge.net/p/pthreads4w/code/merge-requests/6/
        ${PATCH_FILES}
)

file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" DESTROOT_DEBUG)
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" DESTROOT_RELEASE)

set(TARGETS_DEBUG "")
set(TARGETS_RELEASE "")
set(_VCPKG_BUILD_TYPE ${VCPKG_BUILD_TYPE})

foreach(_TARGET_BASENAME IN ITEMS VC VCE VSE)
  set(_TARGET ${_TARGET_BASENAME})

  if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(APPEND _TARGET -static)
  endif()
  
  if(NOT DEFINED _VCPKG_BUILD_TYPE OR _VCPKG_BUILD_TYPE STREQUAL debug)
    vcpkg_list(APPEND _TARGETS_DEBUG ${_TARGET}-debug)
  endif()

  if(NOT DEFINED _VCPKG_BUILD_TYPE OR _VCPKG_BUILD_TYPE STREQUAL release)
    vcpkg_list(APPEND _TARGETS_RELEASE ${_TARGET})
  endif()
endforeach()

vcpkg_build_nmake(
  SOURCE_PATH ${SOURCE_PATH}
  PROJECT_NAME Makefile
  TARGET clean
  OPTIONS_DEBUG ${_TARGETS_DEBUG} install "DESTROOT=\"${DESTROOT_DEBUG}\""
  OPTIONS_RELEASE ${_TARGETS_RELEASE} install "DESTROOT=\"${DESTROOT_RELEASE}\""
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVC3.lib")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVCE3.lib")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVSE3.lib")
endif()

if(NOT DEFINED _VCPKG_BUILD_TYPE OR _VCPKG_BUILD_TYPE STREQUAL debug)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVC3d.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVCE3d.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVSE3d.lib")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/PThreads4WConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads4W")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthread.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthread" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthreads" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads-windows.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads_windows" RENAME vcpkg-cmake-wrapper.cmake)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
