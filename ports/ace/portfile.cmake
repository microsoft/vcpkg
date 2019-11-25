include(vcpkg_common_functions)

# Don't change to vcpkg_from_github! This points to a release and not an archive
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_7/ACE-src-6.5.7.zip"
    FILENAME ACE-src-6.5.7.zip
    SHA512 6ce6954941521b34ae8913dfe053d0f066632c55adf4091dae6bc180c79963d6f4ddfec7796cd6d9fc8ff59037ee162d20b017c4c296828913498bdbac2fc8a7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

set(ACE_ROOT ${SOURCE_PATH})
set(ENV{ACE_ROOT} ${ACE_ROOT})
set(ACE_SOURCE_PATH ${ACE_ROOT}/ace)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

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

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

if (TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM is currently not supported.")
elseif (TRIPLET_SYSTEM_ARCH MATCHES "x86")
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
vcpkg_execute_required_process(
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
  file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/ace/copyright)
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
  vcpkg_execute_required_process(
    COMMAND make ${_ace_makefile_macros} "debug=1" "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME make-${TARGET_TRIPLET}-dbg
  )
  message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
  if(TRUE)
    # Helper codes that logs some infomation that might be useful
    # This codes should not be activated in real production use.
    vcpkg_execute_required_process(
      COMMAND ls -al
      WORKING_DIRECTORY ${ACE_ROOT}
      LOGNAME ace_root_ls-${TARGET_TRIPLET}
    )
    vcpkg_execute_required_process(
      COMMAND ls -al
      WORKING_DIRECTORY ${ACE_ROOT}/MPC
      LOGNAME ace_root_mpc_ls-${TARGET_TRIPLET}
    )
  endif()
  message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_required_process(
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

  vcpkg_execute_required_process(
    COMMAND make ${_ace_makefile_macros} realclean
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME realclean-${TARGET_TRIPLET}-dbg
  )

  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND make ${_ace_makefile_macros} "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME make-${TARGET_TRIPLET}-rel
  )
  message(STATUS "Building ${TARGET_TRIPLET}-rel done")
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND make ${_ace_makefile_macros} install
    WORKING_DIRECTORY ${ACE_ROOT}/ace
    LOGNAME install-${TARGET_TRIPLET}-rel
  )
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")
  # Restore `PWD` environment variable
  set($ENV{PWD} _prev_env)

  # Handle copyright
  file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/ace/copyright)
endif()