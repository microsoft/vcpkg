if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

set(PTHREADS4W_VERSION "3.0.0")

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
    FILENAME "pthreads4w-code-v${PTHREADS4W_VERSION}.zip"
    SHA512 49e541b66c26ddaf812edb07b61d0553e2a5816ab002edc53a38a897db8ada6d0a096c98a9af73a8f40c94283df53094f76b429b09ac49862465d8697ed20013
    PATCHES
        fix-arm-macro.patch
        ${PATCH_FILES}
)

find_program(NMAKE nmake REQUIRED)

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f Makefile all install
        "DESTROOT=\"${INST_DIR_REL}\""
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVC3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVCE3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVSE3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVC3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVCE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVSE3d.lib")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3.lib")
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVC3.lib")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVCE3.lib")
  file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3.lib" "${CURRENT_PACKAGES_DIR}/lib/pthreadVSE3.lib")
endif()

message(STATUS "Building ${TARGET_TRIPLET}-rel done")

if(NOT VCPKG_BUILD_TYPE)
    ################
    # Debug build
    ################
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} /G -f Makefile all install
            "DESTROOT=\"${INST_DIR_DBG}\""
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME nmake-build-${TARGET_TRIPLET}-debug
    )
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVC3.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVCE3.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVSE3.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3.lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3.lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3.lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVC3.lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVCE3.lib")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVSE3.lib")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3d.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3d.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3d.lib")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVC3d.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVCE3d.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVSE3d.lib")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
endif()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/PThreads4WConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads4W")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthread.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthread" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pthreads" RENAME vcpkg-cmake-wrapper.cmake)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper-pthreads-windows.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/PThreads_windows" RENAME vcpkg-cmake-wrapper.cmake)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
