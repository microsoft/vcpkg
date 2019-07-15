include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "Error: the port is unsupported on your platform. Please open an issue on github.com/Microsoft/vcpkg to request a fix")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install autoreconf libudev-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF v1.0.22
    SHA512 b1fed66aafa82490889ee488832c6884a95d38ce7b28fb7c3234b9bce1f749455d7b91cde397a0abc25101410edb13ab2f9832c59aa7b0ea8c19ba2cf4c63b00
    HEAD_REF master
    PATCHES
        fix_c2001.patch
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(MSVS_VERSION 2017)  #they are abi compatible, so it should work
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(MSVS_VERSION 2017)
  else()
    set(MSVS_VERSION 2015)
  endif()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(LIBUSB_PROJECT_TYPE dll)
  else()
      set(LIBUSB_PROJECT_TYPE static)
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
