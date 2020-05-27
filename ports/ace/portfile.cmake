vcpkg_fail_port_install(ON_TARGET "uwp")

# Using zip archive under Linux would cause sh/perl to report "No such file or directory" or "bad interpreter"
# when invoking `prj_install.pl`.
# So far this issue haven't yet be triggered under WSL 1 distributions. Not sure the root cause of it.
if("tao" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_WINDOWS)
      # Don't change to vcpkg_from_github! This points to a release and not an archive
      vcpkg_download_distfile(ARCHIVE
          URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_9/ACE%2BTAO-src-6.5.9.zip"
          FILENAME ACE-TAO-6.5.9.zip
          SHA512 de626d693911ea6b43001b16183996bd537777b42530a95ef226265948802b87aaac935d92265f1dda39c864a875d669a10cdcb0083e3dc7c3f5f661a5ee9d79
      )
    else()
      # VCPKG_TARGET_IS_LINUX
      vcpkg_download_distfile(ARCHIVE
          URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_9/ACE%2BTAO-src-6.5.9.tar.gz"
          FILENAME ACE-TAO-6.5.9.tar.gz
          SHA512 d53b7a3745d1be29489d495651a643cf8b436be97a21599bbe4fba19b827cb1ba85dca82542e0eb27384fe87ab163e69c5e0c4c9b61a4c7971077b13edece5cd
      )
    endif()
else()
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
if("tao" IN_LIST FEATURES)
  set(TAO_ROOT ${SOURCE_PATH}/TAO)
  set(ENV{TAO_ROOT} ${TAO_ROOT})
  set(WORKSPACE ${TAO_ROOT}/TAO_ACE)
else()
  set(WORKSPACE ${ACE_ROOT}/ace/ace)
endif()
if("wchar" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "uses_wchar=1")
endif()
if("zlib" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "zlib=1")
    set(ENV{ZLIB_ROOT} ${CURRENT_INSTALLED_DIR})
else()
    list(APPEND ACE_FEATURE_LIST "zlib=0")
endif()
if("ssl" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "ssl=1")
    list(APPEND ACE_FEATURE_LIST "openssl11=1")
    set(ENV{SSL_ROOT} ${CURRENT_INSTALLED_DIR})
else()
    list(APPEND ACE_FEATURE_LIST "ssl=0")
endif()
list(JOIN ACE_FEATURE_LIST "," ACE_FEATURES)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
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
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(SOLUTION_TYPE vs2019)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(SOLUTION_TYPE vs2017)
  else()
    set(SOLUTION_TYPE vc14)
  endif()
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"")
elseif(VCPKG_TARGET_IS_LINUX)
  set(SOLUTION_TYPE gnuace)
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-linux.h\"")
  file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU")
elseif(VCPKG_TARGET_IS_OSX)
  set(SOLUTION_TYPE gnuace)
  file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-macosx.h\"")
  file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_macosx.GNU")
endif()

# Invoke mwc.pl to generate the necessary solution and project files
vcpkg_execute_build_process(
    COMMAND ${PERL} ${ACE_ROOT}/bin/mwc.pl -type ${SOLUTION_TYPE} -features "${ACE_FEATURES}" ${WORKSPACE}.mwc ${MPC_STATIC_FLAG}
    WORKING_DIRECTORY ${ACE_ROOT}
    LOGNAME mwc-${TARGET_TRIPLET}
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(RELATIVE_PATH PROJECT_SUBPATH ${SOURCE_PATH} ${WORKSPACE}.sln)
  vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH ${PROJECT_SUBPATH}
    LICENSE_SUBPATH COPYING
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
  )
  
  # ACE itself does not define an install target, so it is not clear which
  # headers are public and which not. For the moment we install everything
  # that is in the source path and ends in .h, .inl
  function(install_ace_headers_subdirectory ORIGINAL_PATH RELATIVE_PATH)
    file(GLOB HEADER_FILES 
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.h 
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.hpp
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.inl 
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.idl
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.pidl
    )
    file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${RELATIVE_PATH})
  endfunction()

  # We manually install cpp files found in the ace directory
  # see ACE_wrappers\debian\libace-dev.install file
  file(GLOB ACE_SOURCE_FILES ${ACE_SOURCE_PATH}/*.cpp)
  file(INSTALL ${ACE_SOURCE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/ace/)

  # Install headers in subdirectory
  install_ace_headers_subdirectory(${ACE_ROOT} "ace")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/Compression")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/Compression/rle")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/ETCL")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/QoS")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/Monitor_Control")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/os_include")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/os_include/arpa")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/os_include/net")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/os_include/netinet")
  install_ace_headers_subdirectory(${ACE_ROOT} "ace/os_include/sys")
  if("ssl" IN_LIST FEATURES)
      install_ace_headers_subdirectory(${ACE_ROOT} "ace/SSL")
  endif()
  if("tao" IN_LIST FEATURES)
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML")
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML/apps")
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML/apps/svcconf")
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML/common")
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML/parser")
    install_ace_headers_subdirectory(${ACE_ROOT} "ACEXML/parser/parser")
    install_ace_headers_subdirectory(${ACE_ROOT}/protocols "ace/HTBP")
    install_ace_headers_subdirectory(${ACE_ROOT}/protocols "ace/INet")
    install_ace_headers_subdirectory(${ACE_ROOT}/protocols "ace/RMCast")
    install_ace_headers_subdirectory(${ACE_ROOT}/protocols "ace/TMCast")
    install_ace_headers_subdirectory(${ACE_ROOT} "Kokyu")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/AV")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Concurrency")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/CosEvent")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Event")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/FaultTolerance")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/FtRtEvent/ClientORB")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/FtRtEvent/EventChannel")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/FtRtEvent/Utils")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/HTIOP")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/IFRService")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/LifeCycle")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/LoadBalancing")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Log")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Naming")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Naming/FaultTolerant")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify/Any")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify/MonitorControl")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify/MonitorControlExt")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify/Sequence")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Notify/Structured")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/PortableGroup")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Property")
    install_ace_headers_subdirectory(${TAO_ROOT} "orbsvcs/FT_ReplicationManager")
    install_ace_headers_subdirectory(${TAO_ROOT} "orbsvcs/Notify_Service")
    if("ssl" IN_LIST FEATURES)
        install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/SSLIOP")
    endif()
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Sched")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Security")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Time")
    install_ace_headers_subdirectory(${TAO_ROOT}/orbsvcs "orbsvcs/Trader")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/AnyTypeCode")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/BiDir_GIOP")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/CSD_Framework")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/CSD_ThreadPool")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/CodecFactory")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Codeset")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Compression")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Compression/rle")
    if("zlib" IN_LIST FEATURES)
        install_ace_headers_subdirectory(${TAO_ROOT} "tao/Compression/zlib")
    endif()
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/DiffServPolicy")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/DynamicAny")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/DynamicInterface")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Dynamic_TP")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/ETCL")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/EndpointPolicy")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/IFR_Client")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/IORInterceptor")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/IORManipulation")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/IORTable")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/ImR_Client")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Messaging")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Monitor")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/ObjRefTemplate")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/PI")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/PI_Server")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/PortableServer")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/RTCORBA")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/RTPortableServer")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/RTScheduling")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/SmartProxies")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Strategies")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/TransportCurrent")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/TypeCodeFactory")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Utils")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/Valuetype")
    install_ace_headers_subdirectory(${TAO_ROOT} "tao/ZIOP")
  endif()
  
  # Remove dlls without any export
  if("tao" IN_LIST FEATURES)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
      file(REMOVE 
        ${CURRENT_PACKAGES_DIR}/bin/ACEXML_XML_Svc_Conf_Parser.dll 
        ${CURRENT_PACKAGES_DIR}/bin/ACEXML_XML_Svc_Conf_Parser.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/ACEXML_XML_Svc_Conf_Parserd.dll
        ${CURRENT_PACKAGES_DIR}/debug/bin/ACEXML_XML_Svc_Conf_Parserd_dll.pdb)
    endif()
  endif()
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
  FIND_PROGRAM(MAKE make)
  IF (NOT MAKE)
    MESSAGE(FATAL_ERROR "MAKE not found")
  ENDIF ()

  if("ssl" IN_LIST FEATURES)
    list(APPEND _ace_makefile_macros "ssl=1")
  endif()

  set(ENV{INSTALL_PREFIX} ${CURRENT_PACKAGES_DIR})
  # Set `PWD` environment variable since ACE's `install` make target calculates install dir using this env.
  set(_prev_env $ENV{PWD})
  get_filename_component(WORKING_DIR ${WORKSPACE} DIRECTORY)
  set(ENV{PWD} ${WORKING_DIR})

  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} "debug=1" "optimize=0" "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME make-${TARGET_TRIPLET}-dbg
  )
  message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
  message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} install
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME install-${TARGET_TRIPLET}-dbg
  )

  file(COPY ${CURRENT_PACKAGES_DIR}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)

  file(GLOB _pkg_components ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc)
  foreach(_pkg_comp ${_pkg_components})
    file(READ ${_pkg_comp} _content)
    string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/lib" "libdir=${CURRENT_PACKAGES_DIR}/debug/lib" _content ${_content})
    file(WRITE ${_pkg_comp} ${_content})
  endforeach()
  message(STATUS "Packaging ${TARGET_TRIPLET}-dbg done")

  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} realclean
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME realclean-${TARGET_TRIPLET}-dbg
  )

  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} "-j${VCPKG_CONCURRENCY}"
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME make-${TARGET_TRIPLET}-rel
  )
  message(STATUS "Building ${TARGET_TRIPLET}-rel done")
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
  vcpkg_execute_build_process(
    COMMAND make ${_ace_makefile_macros} install
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME install-${TARGET_TRIPLET}-rel
  )
  if("tao" IN_LIST FEATURES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  endif()
  message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")
  # Restore `PWD` environment variable
  set($ENV{PWD} _prev_env)

  # Handle copyright
  file(INSTALL ${ACE_ROOT}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()
