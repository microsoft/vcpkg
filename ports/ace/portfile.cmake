vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

# Using zip archive under Linux would cause sh/perl to report "No such file or directory" or "bad interpreter"
# when invoking `prj_install.pl`.
# So far this issue haven't yet be triggered under WSL 1 distributions. Not sure the root cause of it.
if(VCPKG_TARGET_IS_WINDOWS)
  # Don't change to vcpkg_from_github! This points to a release and not an archive
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_8/ACE-src-6.5.8.zip"
      FILENAME ACE-src-6.5.8.zip
      SHA512 e0fd30de81f0d6e629394fc9cb814ecb786c67fccd7e975a3d64cf0859d5a03ba5a5ae4bb0a6ce5e6d16395a48ffa28f5a1a92758e08a3fd7d55582680f94d82
  )
else(VCPKG_TARGET_IS_WINDOWS)
  # VCPKG_TARGET_IS_LINUX
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_8/ACE-src-6.5.8.tar.gz"
      FILENAME ACE-src-6.5.8.tar.gz
      SHA512 45ee6cf4302892ac9de305f8454109fa17a8b703187cc76555ce3641b621909e0cfedf3cc4a7fe1a8f01454637279cc9c4afe9d67466d5253e0ba1f34431d97f
  )
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
endif()

if(VCPKG_TARGET_IS_LINUX)
  set(DLL_DECORATOR)
  set(LIB_RELEASE_SUFFIX .a)
  set(LIB_DEBUG_SUFFIX .a)
  set(LIB_PREFIX lib)
  set(SOLUTION_TYPE gnuace)
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-linux.h\"")
  file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU")
endif()

# Invoke mwc.pl to generate the necessary solution and project files
vcpkg_execute_build_process(
    COMMAND ${PERL} ${ACE_ROOT}/bin/mwc.pl -type ${SOLUTION_TYPE} -features "${ACE_FEATURES}" ace ${MPC_STATIC_FLAG}
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
  function(install_ace_headers_subdirectory ORIGINAL_PATH RELATIVE_PATH)
  file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.h ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.inl)
  file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/${RELATIVE_PATH})
  endfunction()

  # We manually install header found in the ace directory because in that case
  # we are supposed to install also *cpp files, see ACE_wrappers\debian\libace-dev.install file
  file(GLOB HEADER_FILES ${ACE_SOURCE_PATH}/*.h ${ACE_SOURCE_PATH}/*.inl ${ACE_SOURCE_PATH}/*.cpp)
  file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/)

  # Install headers in subdirectory
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "Compression")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "Compression/rle")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "ETCL")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "QoS")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "Monitor_Control")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "os_include")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "os_include/arpa")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "os_include/net")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "os_include/netinet")
  install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "os_include/sys")
  if("ssl" IN_LIST FEATURES)
      install_ace_headers_subdirectory(${ACE_SOURCE_PATH} "SSL")
  endif()

  # Install the libraries
  function(install_ace_library ORIGINAL_PATH ACE_LIBRARY)
  set(LIB_PATH ${ORIGINAL_PATH}/lib/)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
      # Install the DLL files
      file(INSTALL
          ${LIB_PATH}/${ACE_LIBRARY}d.dll
          DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
      )
      file(INSTALL
          ${LIB_PATH}/${ACE_LIBRARY}.dll
          DESTINATION ${CURRENT_PACKAGES_DIR}/bin
      )
  endif()

  # Install the lib files
  file(INSTALL
      ${LIB_PATH}/${LIB_PREFIX}${ACE_LIBRARY}${DLL_DECORATOR}${LIB_DEBUG_SUFFIX}
      DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
  )

  file(INSTALL
      ${LIB_PATH}/${LIB_PREFIX}${ACE_LIBRARY}${DLL_DECORATOR}${LIB_RELEASE_SUFFIX}
      DESTINATION ${CURRENT_PACKAGES_DIR}/lib
  )
  endfunction()

  install_ace_library(${ACE_ROOT} "ACE")
  install_ace_library(${ACE_ROOT} "ACE_Compression")
  install_ace_library(${ACE_ROOT} "ACE_ETCL")
  install_ace_library(${ACE_ROOT} "ACE_ETCL_Parser")
  install_ace_library(${ACE_ROOT} "ACE_Monitor_Control")
  if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    install_ace_library(${ACE_ROOT} "ACE_QoS")
  endif()
  install_ace_library(${ACE_ROOT} "ACE_RLECompression")
  if("ssl" IN_LIST FEATURES)
      install_ace_library(${ACE_ROOT} "ACE_SSL")
  endif()

  vcpkg_copy_pdbs()

  # Handle copyright
  file(COPY ${ACE_ROOT}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ace)
  file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
else(VCPKG_TARGET_IS_WINDOWS)
  # VCPKG_TARGTE_IS_LINUX
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
  file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
endif()
