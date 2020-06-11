# Using zip archive under Linux would cause sh/perl to report "No such file or directory" or "bad interpreter"
# when invoking `prj_install.pl`.
# So far this issue haven't yet be triggered under WSL 1 distributions. Not sure the root cause of it.
if(VCPKG_TARGET_IS_WINDOWS)
  # Don't change to vcpkg_from_github! This points to a release and not an archive
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_9/ACE-src-6.5.9.zip"
      FILENAME ACE-src-6.5.9.zip
      SHA512 49e2e5f9d0a88ae1b8a75aacb962e4185a9f8c8aae6cde656026267524bcef8a673514fe35709896a1c4e356cb436b249ff5e3d487e8f3fa2e618e2fb813fa43
  )
else(VCPKG_TARGET_IS_WINDOWS)
  # VCPKG_TARGET_IS_LINUX
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_9/ACE-src-6.5.9.tar.gz"
      FILENAME ACE-src-6.5.9.tar.gz
      SHA512 3e1655d4b215b5195a29b22f2e43d985d68367294df98da251dbbedecd6bdb5662a9921faac43be5756cb2fca7a840d58c6ec92637da7fb9d1b5e2bca766a1b4
  )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        process_manager.patch # Fix MSVC 16.5 ICE
)

set(ACE_ROOT ${SOURCE_PATH})
set(ENV{ACE_ROOT} ${ACE_ROOT})
set(ACE_SOURCE_PATH ${ACE_ROOT}/ace)

if("wchar" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "uses_wchar=1")
endif()
if("zlib" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "zlib=1")
else()
    list(APPEND ACE_FEATURE_LIST "zlib=0")
endif()
if("ssl" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "ssl=1")
    list(APPEND ACE_FEATURE_LIST "openssl11=1")
else()
    list(APPEND ACE_FEATURE_LIST "ssl=0")
endif()
list(JOIN ACE_FEATURE_LIST "," ACE_FEATURES)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(DLL_DECORATOR s)
  endif()
  set(MPC_STATIC_FLAG -static)
endif()

# Acquire Perl and add it to PATH (for execution of MPC)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

# Add ace/config.h file
# see https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html
if(VCPKG_TARGET_IS_WINDOWS)
  set(DLL_RELEASE_SUFFIX .dll)
  set(DLL_DEBUG_SUFFIX d.dll)
  set(LIB_RELEASE_SUFFIX .lib)
  set(LIB_DEBUG_SUFFIX d.lib)
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(SOLUTION_TYPE vs2019)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(SOLUTION_TYPE vs2017)
  else()
    set(SOLUTION_TYPE vc14)
  endif()
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"")
elseif(VCPKG_TARGET_IS_LINUX)
  set(DLL_DECORATOR)
  set(DLL_RELEASE_SUFFIX .so)
  set(DLL_DEBUG_SUFFIX .so)
  set(LIB_RELEASE_SUFFIX .a)
  set(LIB_DEBUG_SUFFIX .a)
  set(LIB_PREFIX lib)
  set(SOLUTION_TYPE gnuace)
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-linux.h\"")
  file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU")
elseif(VCPKG_TARGET_IS_OSX)
  set(DLL_DECORATOR)
  set(DLL_RELEASE_SUFFIX .dylib)
  set(DLL_DEBUG_SUFFIX .dylib)
  set(LIB_RELEASE_SUFFIX .a)
  set(LIB_DEBUG_SUFFIX .a)
  set(SOLUTION_TYPE gnuace)
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-macosx.h\"")
  file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_macosx.GNU")
endif()

if(VCPKG_TARGET_IS_UWP)
  set(MPC_VALUE_TEMPLATE -value_template link_options+=/APPCONTAINER)
endif()

# Invoke mwc.pl to generate the necessary solution and project files
vcpkg_execute_build_process(
    COMMAND ${PERL} ${ACE_ROOT}/bin/mwc.pl -type ${SOLUTION_TYPE} -features "${ACE_FEATURES}" ace ${MPC_STATIC_FLAG} ${MPC_VALUE_TEMPLATE}
    WORKING_DIRECTORY ${ACE_ROOT}
    LOGNAME mwc-${TARGET_TRIPLET}
)

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_build_msbuild(
    PROJECT_PATH ${ACE_SOURCE_PATH}/ace.sln
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
  )

  # ACE itself does not define an install target, so it is not clear which
  # headers are public and which not. For the moment we install everything
  # that is in the source path and ends in .h, .inl
  function(install_includes SOURCE_PATH SUBDIRECTORIES INCLUDE_DIR)
    foreach(SUB_DIR ${SUBDIRECTORIES})
      file(GLOB HEADER_FILES ${SOURCE_PATH}/${SUB_DIR}/*.h ${SOURCE_PATH}/${SUB_DIR}/*.inl ${SOURCE_PATH}/${SUB_DIR}/*.cpp)
      file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${INCLUDE_DIR}/${SUB_DIR})
    endforeach()
  endfunction()

  # Install headers
  set(ACE_INCLUDE_FOLDERS "." "Compression" "Compression/rle" "ETCL" "QoS" "Monitor_Control" "os_include" "os_include/arpa" "os_include/net" "os_include/netinet" "os_include/sys")
  install_includes(${ACE_SOURCE_PATH} "${ACE_INCLUDE_FOLDERS}" "ace")
  if("ssl" IN_LIST FEATURES)
      set(ACE_INCLUDE_FOLDERS "SSL")
      install_includes(${ACE_SOURCE_PATH} "${ACE_INCLUDE_FOLDERS}" "ace")
  endif()

  # Install the libraries
  function(install_libraries SOURCE_PATH LIBRARIES)
    foreach(LIBRARY ${LIBRARIES})
      set(LIB_PATH ${SOURCE_PATH}/lib/)
      if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        # Install the DLL files
        file(INSTALL
          ${LIB_PATH}/${LIBRARY}${DLL_DEBUG_SUFFIX}
          DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
        )
        file(INSTALL
          ${LIB_PATH}/${LIBRARY}${DLL_RELEASE_SUFFIX}
          DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        )
      endif()

      # Install the lib files
      file(INSTALL
          ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_DEBUG_SUFFIX}
          DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
      )

      file(INSTALL
          ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_RELEASE_SUFFIX}
          DESTINATION ${CURRENT_PACKAGES_DIR}/lib
      )
    endforeach()
  endfunction()

  set(ACE_LIBRARIES "ACE" "ACE_Compression" "ACE_ETCL" "ACE_ETCL_Parser" "ACE_Monitor_Control" "ACE_QoS" "ACE_RLECompression")
  install_libraries(${ACE_ROOT} "${ACE_LIBRARIES}")

  if("ssl" IN_LIST FEATURES)
    set(ACE_LIBRARIES "ACE_SSL")
    install_libraries(${ACE_ROOT} "${ACE_LIBRARIES}")
  endif()

  vcpkg_copy_pdbs()

  # Handle copyright
  file(INSTALL ${ACE_ROOT}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
  FIND_PROGRAM(MAKE make)
  IF (NOT MAKE)
    MESSAGE(FATAL_ERROR "MAKE not found")
  ENDIF ()

  list(APPEND _pkg_components ACE_ETCL_Parser ACE_ETCL ACE)
  if("ssl" IN_LIST FEATURES)
    list(APPEND _ace_makefile_macros "ssl=1")
    set(ENV{SSL_ROOT} ${CURRENT_INSTALLED_DIR})
    list(APPEND _pkg_components ACE_SSL)
  endif()
  set(ENV{INSTALL_PREFIX} ${CURRENT_PACKAGES_DIR})
  # Set `PWD` environment variable since ACE's `install` make target calculates install dir using this env.
  set(_prev_env $ENV{PWD})
  set(ENV{PWD} ${ACE_ROOT}/ace)

  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} "debug=1" "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME make-${TARGET_TRIPLET}-dbg
  )
  message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
  message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} install
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME install-${TARGET_TRIPLET}-dbg
  )
  file(COPY ${CURRENT_PACKAGES_DIR}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
  # TODO: check if we really need to remove those directories
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)
  foreach(_pkg_comp ${_pkg_components})
    file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_pkg_comp}.pc _content)
    string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/lib" "libdir=${CURRENT_PACKAGES_DIR}/debug/lib" _content ${_content})
    file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_pkg_comp}.pc ${_content})
  endforeach()
  message(STATUS "Packaging ${TARGET_TRIPLET}-dbg done")

  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} realclean
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME realclean-${TARGET_TRIPLET}-dbg
  )

  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME make-${TARGET_TRIPLET}-rel
  )
  message(STATUS "Building ${TARGET_TRIPLET}-rel done")
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} install
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME install-${TARGET_TRIPLET}-rel
  )
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")
  # Restore `PWD` environment variable
  set($ENV{PWD} _prev_env)

  # Handle copyright
  file(INSTALL ${ACE_ROOT}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()
