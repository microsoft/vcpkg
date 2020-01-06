vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install autoreconf libudev-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF e782eeb2514266f6738e242cdcb18e3ae1ed06fa # v1.0.23
    SHA512 27cfff4bbf64d5ec5014acac0871ace74b6af76141bd951309206f4806e3e3f2c7ed32416f5b55fd18d033ca5494052eb2e50ed3cc0be10839be2bd4168a9d4c
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(MSVS_VERSION 2017)  #they are abi compatible, so it should work
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(MSVS_VERSION 2017)
  else()
    set(MSVS_VERSION 2015)
  endif()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(LIBUSB_PROJECT_TYPE dll)
      if (VCPKG_CRT_LINKAGE STREQUAL static)
        file(READ "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" PROJ_FILE)
        string(REPLACE "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        string(REPLACE "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        file(WRITE "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" "${PROJ_FILE}")
      endif()
  else()
      set(LIBUSB_PROJECT_TYPE static)
      if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        file(READ "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" PROJ_FILE)
        string(REPLACE "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        string(REPLACE "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        file(WRITE "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" "${PROJ_FILE}")
      endif()
  endif()

  vcpkg_install_msbuild(
      SOURCE_PATH ${SOURCE_PATH}
      PROJECT_SUBPATH msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj
      LICENSE_SUBPATH COPYING
  )
else()
    set(BASH /bin/bash)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Release")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        # Copy sources
        message(STATUS "Copying source files...")
        file(GLOB PORT_SOURCE_FILES ${SOURCE_PATH}/*)
        foreach(SOURCE_FILE ${PORT_SOURCE_FILES})
          file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        endforeach()
        message(STATUS "Copying source files... done")
        # Configure release
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        execute_process(
            COMMAND "${BASH} --noprofile --norc -c \"./autogen.sh\""
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        execute_process(
            COMMAND "${BASH} --noprofile --norc -c \"./configure --prefix=${CURRENT_PACKAGES_DIR}\""
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Debug")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        # Copy sources
        message(STATUS "Copying source files...")
        file(GLOB PORT_SOURCE_FILES ${SOURCE_PATH}/*)
        foreach(SOURCE_FILE ${PORT_SOURCE_FILES})
          file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        endforeach()
        message(STATUS "Copying source files... done")
        # Configure debug
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        execute_process(
            COMMAND "${BASH} --noprofile --norc -c \"./autogen.sh\""
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        execute_process(
            COMMAND "${BASH} --noprofile --norc -c \"./configure --prefix=${CURRENT_PACKAGES_DIR}/debug\""
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
      # Build release
      message(STATUS "Package ${TARGET_TRIPLET}-rel")
      execute_process(
          COMMAND "${BASH} --noprofile --norc -c \"make install\""
          WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
      message(STATUS "Package ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      # Build debug
      message(STATUS "Package ${TARGET_TRIPLET}-dbg")
      execute_process(
          COMMAND "${BASH} --noprofile --norc -c \"make install\""
          WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
      message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
    endif()
endif()

file(INSTALL
    ${SOURCE_PATH}/libusb/libusb.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/libusb-1.0
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
