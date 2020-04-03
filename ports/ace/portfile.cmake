

set(ACE_ROOT ${CURRENT_BUILDTREES_DIR}/src/ACE_wrappers)
set(TAO_ROOT ${ACE_ROOT}/tao)
set(ENV{ACE_ROOT} ${ACE_ROOT})
set(ENV{TAO_ROOT} ${TAO_ROOT})
set(ACE_SOURCE_PATH ${ACE_ROOT}/ace)
set(TAO_SOURCE_PATH ${TAO_ROOT}/tao)

set(INSTALLED_PATH ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET})
if(${CMAKE_BUILD_TYPE} MATCHES "^Debug$")
set(INSTALLED_PATH ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug)
endif()


###################################################
#
#   Download and extract
#
###################################################

# Using zip archive under Linux would cause sh/perl to report "No such file or directory" or "bad interpreter"
# when invoking `prj_install.pl`.
# So far this issue haven't yet be triggered under WSL 1 distributions. Not sure the root cause of it.
if(VCPKG_TARGET_IS_WINDOWS)
  # Don't change to vcpkg_from_github! This points to a release and not an archive
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_8/ACE+TAO-src-6.5.8.zip"
      FILENAME ACE+TAO-src-6.5.8.zip
      SHA512 847621bdd72b5a6909cbdef1d6e3c8792aa29f0b44e64c49c64c5d87df4fe703c6a27b15465d655e97ca8cc0df7449ac012f90f6de5d82b8e30bfbeb2e7057c2
)
else(VCPKG_TARGET_IS_WINDOWS)
  # VCPKG_TARGET_IS_LINUX
  vcpkg_download_distfile(ARCHIVE
      URLS "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-6_5_8/ACE+TAO-src-6.5.8.tar.gz"
      FILENAME ACE+TAO-src-6.5.8.tar.gz
      SHA512 4440975cac5baaa1d6fce869fbac73f15cf86942df3dab0f06c2309d9e20f6a79d826690138baf2ce5b232a1255d9e09cae0e40bd0cddae3d26ca9eb937871db
)
endif()

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ACE_wrappers
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/arm_prevent_amd64_definition.patch"
        "${CMAKE_CURRENT_LIST_DIR}/bzip2.patch"
)

###################################################
#
#   Generate features string
#
###################################################

# see https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html
if(VCPKG_TARGET_IS_WINDOWS)
    file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"\n#define ACE_NO_INLINE")
elseif(VCPKG_TARGET_IS_LINUX)
    file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-linux.h\"")
    file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU")
elseif(VCPKG_TARGET_IS_OSX)
    file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-macosx.h\"")
    file(WRITE ${ACE_ROOT}/include/makeinclude/platform_macros.GNU "include $(ACE_ROOT)/include/makeinclude/platform_macosx.GNU")
elseif(VCPKG_TARGET_IS_UWP)
    file(WRITE ${ACE_SOURCE_PATH}/config.h "#include \"ace/config-windows.h\"\n#define ACE_NO_INLINE")
endif()

if((VCPKG_TARGET_IS_WINDOWS) OR (VCPKG_TARGET_IS_UWP))
  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DLL_DECORATOR s)
  endif()
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(SOLUTION_TYPE vs2019)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(SOLUTION_TYPE vs2017)
  else()
    set(SOLUTION_TYPE vc14)
  endif()
elseif((VCPKG_TARGET_IS_LINUX) OR (VCPKG_TARGET_IS_OSX))
  set(SOLUTION_TYPE gnuace)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(MPC_STATIC_FLAG -static)
endif()

if("wchar" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "uses_wchar=1")
else()
    list(APPEND ACE_FEATURE_LIST "uses_wchar=0")
endif()
if("xml" IN_LIST FEATURES)
    list(APPEND ACE_FEATURE_LIST "xerces3=1")
else()
    list(APPEND ACE_FEATURE_LIST "xerces3=0")
endif()
if("ssl" IN_LIST FEATURES)
    set(ENV{SSL_ROOT} ${INSTALLED_PATH})
    list(APPEND ACE_FEATURE_LIST "ssl=1")
    list(APPEND ACE_FEATURE_LIST "openssl11=1") # use for new lib names (i.e. libcrypto)
else()
    list(APPEND ACE_FEATURE_LIST "ssl=0")
endif()
if("qt5" IN_LIST FEATURES)
    set(QT5_CORE_MPB_PATH "${ACE_ROOT}/MPC/config/qt5_core.mpb")
    FILE(READ ${QT5_CORE_MPB_PATH} QT5_CORE_MPB_DATA)
    STRING(REGEX REPLACE "QT5_BINDIR\\)\\/" "QTDIR)/tools/qt5/bin/" NEW_QT5_CORE_MPB_DATA ${QT5_CORE_MPB_DATA})
    SET(QT5_CORE_MPB_DATA ${NEW_QT5_CORE_MPB_DATA})
    STRING(REGEX REPLACE "libpaths \\+\\= \\$\\(QT5_LIBDIR\\)" "libpaths += $(QT5_LIBDIR) ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/lib" NEW_QT5_CORE_MPB_DATA ${QT5_CORE_MPB_DATA})
    FILE(WRITE ${QT5_CORE_MPB_PATH} "${NEW_QT5_CORE_MPB_DATA}")
    set(ENV{QTDIR} ${INSTALLED_PATH})
    list(APPEND ACE_FEATURE_LIST "qt5=1")
else()
    list(APPEND ACE_FEATURE_LIST "qt5=0")
endif()
if("bzip2" IN_LIST FEATURES)
    set(ENV{BZIP2_ROOT} ${INSTALLED_PATH})
    list(APPEND ACE_FEATURE_LIST "bzip2=1")
else()
    list(APPEND ACE_FEATURE_LIST "bzip2=0")
endif()
if("zlib" IN_LIST FEATURES)
    set(ENV{ZLIB_ROOT} ${INSTALLED_PATH})
    list(APPEND ACE_FEATURE_LIST "zlib=1")
else()
    list(APPEND ACE_FEATURE_LIST "zlib=0")
endif()
if("tao" IN_LIST FEATURES)
    set(BUILD_TAO 1)
else()
    set(BUILD_TAO 0)    
endif()
list(JOIN ACE_FEATURE_LIST "," ACE_FEATURES)
string(PREPEND ACE_FEATURES ",")

###################################################
#
#   Invoke mwc to generate solution / make files
#
###################################################


if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()


# Acquire Perl and add it to PATH (for execution of MPC)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

if(BUILD_TAO)
    set(WORKSPACE "TAO_ACE")
    set(WORKING_DIR ${TAO_ROOT})
else()
    set(WORKSPACE "ACE")
    set(WORKING_DIR ${ACE_ROOT})
endif()

vcpkg_execute_required_process(
    COMMAND ${PERL} ${ACE_ROOT}/bin/mwc.pl -type ${SOLUTION_TYPE} ${WORKSPACE}.mwc ${MPC_STATIC_FLAG} -features stl=1,ace_for_tao=0,ace_inline=0${ACE_FEATURES} -workers ${VCPKG_CONCURRENCY} -use_env -expand_vars
    WORKING_DIRECTORY ${WORKING_DIR}
    LOGNAME mwc-tao-${TARGET_TRIPLET}
)

###################################################
#
#   Build
#
###################################################

# Build for Windows
if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    vcpkg_build_msbuild(PROJECT_PATH "${WORKING_DIR}/${WORKSPACE}.sln" PLATFORM ${MSBUILD_PLATFORM} OPTIONS /m USE_VCPKG_INTEGRATION)
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
  vcpkg_build_make(SOURCE_PATH ${SOURCE_PATH})
endif()

###################################################
#
#   Installation
#
###################################################

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
  set(LIB_RELEASE_SUFFIX .lib)
  set(LIB_DEBUG_SUFFIX d.lib)
  set(DLL_RELEASE_SUFFIX .dll)
  set(DLL_DEBUG_SUFFIX d.dll)
  set(LIB_PREFIX)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DLL_DECORATOR s)
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  set(DLL_DECORATOR)
  set(LIB_RELEASE_SUFFIX .a)
  set(LIB_DEBUG_SUFFIX .a)
  set(DLL_RELEASE_SUFFIX)
  set(DLL_DEBUG_SUFFIX)
  set(LIB_PREFIX lib)
elseif(VCPKG_TARGET_IS_OSX)
  set(DLL_DECORATOR)
  set(LIB_RELEASE_SUFFIX .a)
  set(LIB_DEBUG_SUFFIX .a)
  set(DLL_RELEASE_SUFFIX .dylib)
  set(DLL_DEBUG_SUFFIX .dylib)
  set(LIB_PREFIX lib)
endif()

# Install include files
function(install_includes SOURCE_PATH SUBDIRECTORIES INCLUDE_DIR)
    foreach(SUB_DIR ${SUBDIRECTORIES})
        file(GLOB INCLUDE_FILES ${SOURCE_PATH}/${SUB_DIR}/*.h ${SOURCE_PATH}/${SUB_DIR}/*.inl ${SOURCE_PATH}/${SUB_DIR}/*.cpp)
        file(COPY ${INCLUDE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${INCLUDE_DIR}/${SUB_DIR})
    endforeach()
endfunction()

set(ACE_INCLUDE_FOLDERS "." "Compression" "Compression/rle" "ETCL" "QoS" "Monitor_Control" "os_include" "os_include/arpa" "os_include/net" "os_include/netinet" "os_include/sys")
install_includes(${ACE_SOURCE_PATH} "${ACE_INCLUDE_FOLDERS}" "ace")

if(BUILD_TAO)
    set(TAO_INCLUDE_FOLDERS "." "AnyTypeCode" "BiDir_GIOP" "CodecFactory" "Codeset" "Compression" "Compression/bzip2" "Compression/lzo" "Compression/rle" "Compression/zlib"
        "CSD_Framework" "CSD_ThreadPool" "DiffServPolicy" "Dynamic_TP" "DynamicAny" "DynamicInterface" "EndpointPolicy" "EndpointPolicy" "ETCL" "FlResource" "FoxResource"
        "IFR_Client" "ImR_Client" "IORInterceptor" "IORManipulation" "IORTable" "Messaging" "Monitor" "ObjRefTemplate" "PI" "PI_Server" "PortableServer" "QtResource"
        "RTCORBA" "RTPortableServer" "RTScheduling" "SmartProxies" "Strategies" "TkResource" "TransportCurrent" "TypeCodeFactory" "Utils" "Valuetype" "XtResource" "ZIOP")
    install_includes(${TAO_SOURCE_PATH} "${TAO_INCLUDE_FOLDERS}" "tao")

    set(ORBSVCS_INCLUDE_FOLDERS "." "AV" "Concurrency" "CosEvent" "ESF" "FaultTolerance" "FtRtEvent/ClientORB" "FtRtEvent/EventChannel" "FtRtEvent/Utils" "HTIOP" "IFRService"
        "LifeCycle" "LoadBalancing" "Log" "Naming" "Naming/FaultTolerant" "Notify" "Notify/Any" "Notify/MonitorControl" "Notify/MonitorControlExt" "Notify/Sequence"
        "Notify/Structured" "PortableGroup" "Property" "Sched" "Security" "SSLIOP" "Time" "Trader")
    install_includes(${TAO_ROOT}/orbsvcs/orbsvcs "${ORBSVCS_INCLUDE_FOLDERS}" "orbsvcs")
endif(BUILD_TAO)

# Install libraries
function(install_libraries SOURCE_PATH LIBRARIES)
    foreach(LIBRARY ${LIBRARIES})
        set(LIB_PATH ${SOURCE_PATH}/lib/)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            # Install the DLL files
            if(EXISTS ${LIB_PATH}/${LIBRARY}${DLL_RELEASE_SUFFIX})
                file(COPY ${LIB_PATH}/${LIBRARY}${DLL_RELEASE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
            endif()
            if(EXISTS ${LIB_PATH}/${LIBRARY}${DLL_DEBUG_SUFFIX})
                file(COPY ${LIB_PATH}/${LIBRARY}${DLL_DEBUG_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)       
            endif()
        endif()
        # Install the lib files
        if(EXISTS ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_RELEASE_SUFFIX})
            file(COPY ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_RELEASE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        endif()
        if(EXISTS ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_DEBUG_SUFFIX})
            file(COPY ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_DEBUG_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        endif()         
    endforeach()
endfunction()

set(ACE_TAO_LIBRARIES "ACE" "ACE_Compression" "ACE_ETCL" "ACE_ETCL_Parser" "ACE_HTBP" "ACE_INet" "ACE_INet_SSL"
    "ACE_Monitor_Control" "ACE_QoS" "ACE_QtReactor" "ACE_RLECompression" "ACE_RMCast" "ACE_SSL" 
    "ACE_TMCast" "ACEXML" "ACEXML_Parser" "Kokyu" "TAO" "TAO_AnyTypeCode" "TAO_Async_ImR_Client_IDL"
    "TAO_Async_IORTable" "TAO_AV" "TAO_BiDirGIOP" "TAO_Bzip2Compressor" "TAO_Catior_i" "TAO_CodecFactory" "TAO_Codeset" 
    "TAO_Compression" "TAO_CosConcurrency" "TAO_CosConcurrency_Serv" "TAO_CosConcurrency_Skel" "TAO_CosEvent"
    "TAO_CosEvent_Serv"  "TAO_CosEvent_Skel" "TAO_CosLifeCycle" "TAO_CosLifeCycle_Skel" "TAO_CosLoadBalancing"
    "TAO_CosNaming" "TAO_CosNaming_Serv" "TAO_CosNaming_Skel" "TAO_CosNotification" "TAO_CosNotification_MC"
    "TAO_CosNotification_MC_Ext"
    "TAO_CosNotification_Serv" "TAO_CosNotification_Skel" "TAO_CosNotification_Persist" "TAO_CosProperty"
    "TAO_CosProperty_Serv" "TAO_CosProperty_Skel" "TAO_CosTime" "TAO_CosTime_Serv" "TAO_CosTrading"
    "TAO_CosTrading_Serv" "TAO_CosTrading_Skel" "TAO_CSD_Framework" "TAO_CSD_ThreadPool" "TAO_DiffServPolicy"
    "TAO_DsEventLogAdmin" "TAO_DsEventLogAdmin_Serv" "TAO_DsEventLogAdmin_Skel" "TAO_DsLogAdmin"
    "TAO_DsLogAdmin_Serv" "TAO_DsLogAdmin_Skel" "TAO_DsNotifyLogAdmin" "TAO_DsNotifyLogAdmin_Serv"
    "TAO_DsNotifyLogAdmin_Skel" "TAO_Dynamic_TP" "TAO_DynamicAny" "TAO_DynamicInterface" "TAO_EndpointPolicy"
    "TAO_ETCL" "TAO_FT_Naming_Serv" "TAO_FT_ServerORB" "TAO_FtNaming" "TAO_FtNamingReplication" 
    "TAO_FTORB_Utils" "TAO_FTRT_ClientORB" "TAO_FTRT_EventChannel" "TAO_FtRtEvent" "TAO_HTIOP" "TAO_IDL_BE"
    "TAO_IDL_FE" "TAO_IFR_BE" "TAO_IFR_Client" "TAO_IFR_Client_skel" "TAO_ImR_Activator_IDL" "TAO_ImR_Client"
    "TAO_ImR_Locator_IDL" "TAO_IORInterceptor" "TAO_IORManip" "TAO_IORTable" "TAO_Messaging" "TAO_Monitor"
    "TAO_Notify_Service" "TAO_ObjRefTemplate" "TAO_PI" "TAO_PI_Server" "TAO_PortableGroup" "TAO_PortableServer" "TAO_QtResource"
    "TAO_ReplicationManagerLib" "TAO_RLECompressor" "TAO_RT_Notification" "TAO_RTCORBA" "TAO_RTEvent" "TAO_RTEvent_Skel"
    "TAO_RTKokyuEvent" "TAO_RTEventLogAdmin" "TAO_RTEventLogAdmin_Skel" "TAO_RTPortableServer" "TAO_RTSched" "TAO_RTScheduler"
    "TAO_Security" "TAO_SmartProxies"  "TAO_Strategies" "TAO_Svc_Utils" "TAO_TC" "TAO_TC_IIOP"
    "TAO_TypeCodeFactory" "TAO_Utils" "TAO_Valuetype" "TAO_ZIOP" "TAO_SSLIOP" 
    "TAO_ZlibCompressor")
install_libraries(${ACE_ROOT} "${ACE_TAO_LIBRARIES}")

# Install executables
function(install_tao_executables SOURCE_PATH EXE_FILE)
    set(EXECUTABLE_SUFFIX ".exe")
    if(VCPKG_TARGET_IS_LINUX)
        set(EXECUTABLE_SUFFIX "")
    endif()
    if(EXISTS "${ACE_ROOT}/bin/${EXE_FILE}${EXECUTABLE_SUFFIX}")
        file(COPY ${ACE_ROOT}/bin/${EXE_FILE}${EXECUTABLE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ace)
    endif()
endfunction()

install_tao_executables(${ACE_ROOT}/bin "ace_gperf")
install_tao_executables(${ACE_ROOT}/bin "tao_catior")
install_tao_executables(${ACE_ROOT}/bin "tao_idl")
install_tao_executables(${ACE_ROOT}/bin "tao_ifr")
install_tao_executables(${ACE_ROOT}/bin "tao_imr")
install_tao_executables(${ACE_ROOT}/bin "tao_nsadd")
install_tao_executables(${ACE_ROOT}/bin "tao_nsdel")
install_tao_executables(${ACE_ROOT}/bin "tao_nsgroup")
install_tao_executables(${ACE_ROOT}/bin "tao_nslist")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${ACE_ROOT}/lib/ACEd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ace)
    if(BUILD_TAO)
        file(COPY ${ACE_ROOT}/lib/TAO_IDL_FEd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ace)
        file(COPY ${ACE_ROOT}/lib/TAO_IDL_BEd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ace)
    endif()
endif()

# Handle copyright
file(COPY ${ACE_ROOT}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ace/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ace/COPYING ${CURRENT_PACKAGES_DIR}/share/ace/copyright)

vcpkg_copy_pdbs()
