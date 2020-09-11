include(vcpkg_common_functions)

set(FASTCGI_VERSION_STR "fc8c6547ae38faf9926205a23075c47fbd4370c8")
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/FastCGI-Archives/fcgi2/archive/${FASTCGI_VERSION_STR}.tar.gz"
    FILENAME "FastCGI-Archives-fcgi2-${FASTCGI_VERSION_STR}.tar.gz"
    SHA512 7f27b1060fbeaf0de9b8a43aa4ff954a004c49e99f7d6ea11119a438fcffe575fb469ba06262e71ac8132f92e74189e2097fd049595a6a61d4d5a5bac2733f7a
)

# Extract source into architecture specific directory, because FCGI2s' nmake based build currently does not
# support out of source builds.
set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/fcgi2-${FASTCGI_VERSION_STR})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/fcgi2-${FASTCGI_VERSION_STR})

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND BUILD_TYPES "release")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND BUILD_TYPES "debug")
endif()

foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
endforeach()

if (VCPKG_TARGET_IS_WINDOWS)
  # Check build system first
  find_program(NMAKE nmake REQUIRED)

  list(APPEND NMAKE_OPTIONS_REL
      ${NMAKE_OPTIONS}
      CFG=release
  )

  list(APPEND NMAKE_OPTIONS_DBG
      ${NMAKE_OPTIONS}
      CFG=debug
  )

  # Begin build process
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    ################
    # Release build
    ################
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    file(RENAME ${SOURCE_PATH_RELEASE}/include/fcgi_config_x86.h ${SOURCE_PATH_RELEASE}/include/fcgi_config.h)
    vcpkg_execute_required_process(
      COMMAND ${NMAKE} /NOLOGO /F libfcgi.mak ${CFG}
      "${NMAKE_OPTIONS_REL}"
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}/libfcgi
      LOGNAME nmake-build-${TARGET_TRIPLET}-release
    )

    file(COPY ${SOURCE_PATH_RELEASE}/libfcgi/Release/libfcgi.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(GLOB FCGI_INCLUDE_FILES ${SOURCE_PATH_RELEASE}/include/*.h)
    file(COPY ${FCGI_INCLUDE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/fastcgi)
    
    if (NOT VCPKG_CRT_LINKAGE STREQUAL static)
        file(COPY ${SOURCE_PATH_RELEASE}/libfcgi/Release/libfcgi.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    message(STATUS "Building ${TARGET_TRIPLET}-rel done")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    ################
    # Debug build
    ################
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    file(RENAME ${SOURCE_PATH_DEBUG}/include/fcgi_config_x86.h ${SOURCE_PATH_DEBUG}/include/fcgi_config.h)
    vcpkg_execute_required_process(
      COMMAND ${NMAKE} /NOLOGO /F libfcgi.mak ${CFG}
      "${NMAKE_OPTIONS_DBG}"
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}/libfcgi
      LOGNAME nmake-build-${TARGET_TRIPLET}-debug
    )
    
    file(COPY ${SOURCE_PATH_DEBUG}/libfcgi/Debug/libfcgi.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    if (NOT VCPKG_CRT_LINKAGE STREQUAL static)
        file(COPY ${SOURCE_PATH_DEBUG}/libfcgi/Debug/libfcgi.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
  endif()

  message(STATUS "Packaging ${TARGET_TRIPLET}")

elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
  # Check build system first
  find_program(AUTOMAKE automake)
  if (NOT AUTOMAKE)
      if(VCPKG_TARGET_IS_OSX)
          message(STATUS "brew install gettext automake")
          vcpkg_execute_required_process(
            COMMAND brew install gettext automake
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME config-${TARGET_TRIPLET}-rel
          )
      else()
          message(STATUS "sudo apt-get install gettext automake")
          vcpkg_execute_required_process(
            COMMAND sudo apt-get install -y gettext automake
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME config-${TARGET_TRIPLET}-rel
          )
      endif()
  endif()
  
  if(VCPKG_TARGET_IS_OSX)
      message(STATUS "brew install libtool")
      vcpkg_execute_required_process(
        COMMAND brew install libtool
        WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
        LOGNAME config-${TARGET_TRIPLET}-rel
      )
  else()
      find_program(LIBTOOL libtool)
      if (NOT LIBTOOL)
          message(STATUS "sudo apt-get install libtool libtool-bin")
          vcpkg_execute_required_process(
            COMMAND sudo apt-get install -y libtool libtool-bin
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME config-${TARGET_TRIPLET}-rel
          )
      endif()
  endif()
  
  find_program(MAKE make)
  if (NOT MAKE)
      message(FATAL_ERROR "MAKE not found")
  endif()

  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    ################
    # Release build
    ################
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    set(OUT_PATH_RELEASE ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
    file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_RELEASE}/autogen.sh"
      WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
      LOGNAME config-${TARGET_TRIPLET}-rel
    )
    
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE}
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
      COMMAND "${SOURCE_PATH_DEBUG}/autogen.sh"
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME config-${TARGET_TRIPLET}-debug
    )
    
    vcpkg_execute_required_process(
      COMMAND "${SOURCE_PATH_DEBUG}/configure" --prefix=${OUT_PATH_DEBUG}
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
      COMMAND make -j install
      WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
      LOGNAME make-install-${TARGET_TRIPLET}-debug
    )

    file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
    message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
  endif()
else() # Other build system
  message(STATUS "Unsupport build system.")
endif()

# Handle copyright
configure_file(${SOURCE_PATH_RELEASE}/LICENSE.TERMS ${CURRENT_PACKAGES_DIR}/share/fastcgi/copyright COPYONLY)
