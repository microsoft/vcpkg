if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  message(FATAL_ERROR "${PORT} does not currently support UWP platform nor ARM architectures")
endif()

set(PTHREADS4W_VERSION "3.0.0")

vcpkg_download_distfile(ARCHIVE
  URLS "https://sourceforge.net/projects/pthreads4w/files/pthreads4w-code-v${PTHREADS4W_VERSION}.zip/download"
  FILENAME "pthreads4w-code-v${PTHREADS4W_VERSION}.zip"
  SHA512 49e541b66c26ddaf812edb07b61d0553e2a5816ab002edc53a38a897db8ada6d0a096c98a9af73a8f40c94283df53094f76b429b09ac49862465d8697ed20013
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  REF ${PTHREADS4W_VERSION}
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
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")

################
# Debug build
################
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /G -f Makefile all install
        "DESTROOT=\"${INST_DIR_DBG}\""
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVC3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVCE3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pthreadVSE3d.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVC3.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVCE3.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/pthreadVSE3.dll")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3.lib")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVC3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVCE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pthreadVSE3d.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVC3.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVCE3.lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVSE3.lib")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3d.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3d.lib")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3d.lib")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpthreadVC3.lib ${CURRENT_PACKAGES_DIR}/lib/pthreadVC3.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpthreadVCE3.lib ${CURRENT_PACKAGES_DIR}/lib/pthreadVCE3.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpthreadVSE3.lib ${CURRENT_PACKAGES_DIR}/lib/pthreadVSE3.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVC3d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVC3d.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVCE3d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVCE3d.lib)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpthreadVSE3d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pthreadVSE3d.lib)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthreads RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthread)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthreads)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/pthreads_windows)

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
