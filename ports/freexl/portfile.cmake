include(vcpkg_common_functions)
set(FREEXL_VERSION_STR "1.0.4")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freexl-${FREEXL_VERSION_STR})
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${FREEXL_VERSION_STR}.tar.gz"
    FILENAME "freexl-${FREEXL_VERSION_STR}.tar.gz"
    SHA512 d72561f7b82e0281cb211fbf249e5e45411a7cdd009cfb58da3696f0a0341ea7df210883bfde794be28738486aeb4ffc67ec2c98fd2acde5280e246e204ce788
)
if (CMAKE_HOST_WIN32)
  vcpkg_extract_source_archive(${ARCHIVE})
  vcpkg_apply_patches(
      SOURCE_PATH ${SOURCE_PATH}
      PATCHES
          ${CMAKE_CURRENT_LIST_DIR}/fix-makefiles.patch
          ${CMAKE_CURRENT_LIST_DIR}/fix-sources.patch
  )
  find_program(NMAKE nmake)

  set(LIBS_ALL_DBG 
    "\"${CURRENT_INSTALLED_DIR}/debug/lib/libiconv.lib\" \
    \"${CURRENT_INSTALLED_DIR}/debug/lib/libcharset.lib\""
    )
  set(LIBS_ALL_REL 
    "\"${CURRENT_INSTALLED_DIR}/lib/libiconv.lib\" \
    \"${CURRENT_INSTALLED_DIR}/lib/libcharset.lib\""
    )


  if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CL_FLAGS_DBG "/MDd /Zi")
    set(CL_FLAGS_REL "/MD /Ox")
  else()
    set(CL_FLAGS_DBG "/MTd /Zi")
    set(CL_FLAGS_REL "/MT /Ox")
  endif()


  ################
  # Debug build
  ################
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      message(STATUS "Building ${TARGET_TRIPLET}-dbg")

      file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug" INST_DIR_DBG)
      vcpkg_execute_required_process(
          COMMAND ${NMAKE} -f makefile.vc clean install
          INST_DIR="${INST_DIR_DBG}" INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}" "LINK_FLAGS=/debug" "CL_FLAGS=${CL_FLAGS_DBG}" "LIBS_ALL=${LIBS_ALL_DBG}"
          WORKING_DIRECTORY ${SOURCE_PATH}
          LOGNAME nmake-build-${TARGET_TRIPLET}-debug
      )
      message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
      vcpkg_copy_pdbs()
  endif()

  ################
  # Release build
  ################
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
      message(STATUS "Building ${TARGET_TRIPLET}-rel")

      file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR_REL)
      vcpkg_execute_required_process(
          COMMAND ${NMAKE} -f makefile.vc clean install
          INST_DIR="${INST_DIR_REL}" INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}" "LINK_FLAGS=" "CL_FLAGS=${CL_FLAGS_REL}" "LIBS_ALL=${LIBS_ALL_REL}"
          WORKING_DIRECTORY ${SOURCE_PATH}
          LOGNAME nmake-build-${TARGET_TRIPLET}-release
      )
      message(STATUS "Building ${TARGET_TRIPLET}-rel done")
  endif()

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
  file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freexl RENAME copyright)

  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib)
  else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/freexl.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
      file(RENAME ${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib ${CURRENT_PACKAGES_DIR}/lib/freexl.lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
      file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib)
    endif()
  endif()

elseif (CMAKE_HOST_UNIX OR CMAKE_HOST_APPLE) # Build in UNIX

    # Check build system first
    find_program(MAKE make)
    if (NOT MAKE)
        message(FATAL_ERROR "MAKE not found")
    endif()

    # CI error logs appear to indicate that it doesn't like ./configure in the same source dir
    # so extract the source into separate debug/release source directories
    set(SOURCE_ROOT_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug)
    set(SOURCE_ROOT_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release)
    set(SOURCE_PATH_DEBUG   ${SOURCE_ROOT_DEBUG}/freexl-${FREEXL_VERSION_STR})
    set(SOURCE_PATH_RELEASE ${SOURCE_ROOT_RELEASE}/freexl-${FREEXL_VERSION_STR})

    file(REMOVE_RECURSE ${SOURCE_ROOT_DEBUG})
    file(REMOVE_RECURSE ${SOURCE_ROOT_RELEASE})

    vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_ROOT_DEBUG})
    vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_ROOT_RELEASE})

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        ################
        # Release build
        ################
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        set(OUT_PATH_RELEASE ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
        file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
        vcpkg_execute_required_process(
            COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE} "${FREEXL_CONFIGURE_ARGS_REL}"
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME config-${TARGET_TRIPLET}-rel
        )

        message(STATUS "Building ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND make
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME make-build-${TARGET_TRIPLET}-release
        )

        message(STATUS "Installing ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND make install
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME make-install-${TARGET_TRIPLET}-release
        )

        file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
        file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
        file(COPY ${SOURCE_PATH_RELEASE}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freexl)
        file(RENAME ${CURRENT_PACKAGES_DIR}/share/freexl/COPYING ${CURRENT_PACKAGES_DIR}/share/freexl/copyright)
        message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        ################
        # Debug build
        ################
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        set(OUT_PATH_DEBUG ${SOURCE_PATH_DEBUG}/../../make-build-${TARGET_TRIPLET}-debug)
        file(MAKE_DIRECTORY ${OUT_PATH_DEBUG})
        vcpkg_execute_required_process(
            COMMAND "${SOURCE_PATH_DEBUG}/configure" --prefix=${OUT_PATH_DEBUG} "${FREEXL_CONFIGURE_ARGS_DBG}"
            WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
            LOGNAME config-${TARGET_TRIPLET}-debug
        )

        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
            COMMAND make
            WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
            LOGNAME make-build-${TARGET_TRIPLET}-debug
        )

        message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
            COMMAND make install
            WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
            LOGNAME make-install-${TARGET_TRIPLET}-debug
        )

        file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
        message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
    endif()

else()# Other build system
    message(FATAL_ERROR "Unsupported build system.")
endif()

message(STATUS "Packaging ${TARGET_TRIPLET} done")
