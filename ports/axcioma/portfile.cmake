if(EXISTS "${CURRENT_INSTALLED_DIR}/share/ace")
    message(FATAL_ERROR "FATAL ERROR: ace and axcioma are incompatible.")
endif()

if(${CMAKE_BUILD_TYPE} MATCHES "^Debug$")
  set(INSTALLED_PATH ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug)
endif()

###################################################
#
#   Download
#
###################################################

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RemedyIT/axcioma
    REF 8a4611cc7354ad6668619d675f6eeb419ee85447
    SHA512 38cd56de659daa203fadc939e8f13c3b22b93585086ef4da3c32cd4ff2ace6ece7eee7c14e30014520e5ef9fe2b8e82c9810e41787ca46f3043dfc4155dec164
    HEAD_REF master
    PATCHES
      fix_osx.patch # PR created: https://github.com/RemedyIT/axcioma/pull/145
)

###################################################
#
#   Boostrap, configuration and generation of files 
#   required to build
#
###################################################

# Acquire Perl and add it to PATH (for execution of MPC)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

# Acquire Ruby and add it to PATH (for execution of brix11 and ridl)
vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH ${RUBY} DIRECTORY)
vcpkg_add_to_path(${RUBY_PATH})

# Acquire Git and add it to PATH (for execution of brix11)
vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_add_to_path(${GIT_PATH})

function(get_git_tag_sha REPO_URL TAG_NAME OUTPUT_VARIABLE)
	set(REF "refs/tags/")
	if(${TAG_NAME} STREQUAL "master")
		set(REF "")
	endif()
  execute_process(
    COMMAND ${GIT} ls-remote ${REPO_URL} ${REF}${TAG_NAME}
    OUTPUT_VARIABLE SHA_VALUE
    RESULT_VARIABLE RESULT
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT ${RESULT} EQUAL 0)
    message(FATAL_ERROR "Failed to get the SHA for the tag '${TAG_NAME}' from the repository '${REPO_URL}'.")
  endif()
  string(REGEX REPLACE "^([0-9a-f]+)\t.*" "\\1" SHA_VALUE ${SHA_VALUE})
  set(${OUTPUT_VARIABLE} ${SHA_VALUE} PARENT_SCOPE)
endfunction()

file(READ ${SOURCE_PATH}/etc/brix11rc BRIX11RC_CONTENT)
string(JSON BRIX11RC_BOOTSTRAP GET ${BRIX11RC_CONTENT} bootstrap)
string(JSON BRIX11RC_BOOTSTRAP_LENGTH LENGTH ${BRIX11RC_BOOTSTRAP})
math(EXPR BRIX11RC_BOOTSTRAP_LENGTH "${BRIX11RC_BOOTSTRAP_LENGTH} - 1")

foreach(IDX RANGE ${BRIX11RC_BOOTSTRAP_LENGTH})
  string(JSON BRIX11RC_ID GET ${BRIX11RC_BOOTSTRAP} ${IDX} id)
	string(JSON BRIX11RC_DIR GET ${BRIX11RC_BOOTSTRAP} ${IDX} dir)
	string(JSON BRIX11RC_REPO GET ${BRIX11RC_BOOTSTRAP} ${IDX} repo)
	string(JSON BRIX11RC_TAG GET ${BRIX11RC_BOOTSTRAP} ${IDX} tag)
	string(JSON BRIX11RC_COL_LENGTH LENGTH ${BRIX11RC_BOOTSTRAP} ${IDX} collections)
	if(NOT EXISTS "${SOURCE_PATH}/${BRIX11RC_DIR}")
		get_git_tag_sha(${BRIX11RC_REPO} ${BRIX11RC_TAG} TAG_SHA)
    if(BRIX11RC_ID STREQUAL "MPC")
      vcpkg_from_git(
        OUT_SOURCE_PATH SUB_SOURCE_PATH
        URL ${BRIX11RC_REPO}
        REF ${TAG_SHA}
        PATCHES mpc_bzip2.patch
      )
    else()
      vcpkg_from_git(
        OUT_SOURCE_PATH SUB_SOURCE_PATH
        URL ${BRIX11RC_REPO}
        REF ${TAG_SHA}
      )
    endif()
		file(RENAME "${SUB_SOURCE_PATH}" "${SOURCE_PATH}/${BRIX11RC_DIR}")
	endif()
endforeach()

set(ACE_ROOT ${SOURCE_PATH}/ACE/ACE)
set(TAO_ROOT ${SOURCE_PATH}/ACE/TAO)
set(MPC_ROOT ${SOURCE_PATH}/ACE/MPC)
set(ACE_SOURCE_PATH ${ACE_ROOT}/ace)
set(TAO_SOURCE_PATH ${TAO_ROOT}/tao)
set(TAOX11_BASE_PATH ${SOURCE_PATH}/taox11)
set(TAOX11_SOURCE_PATH ${TAOX11_BASE_PATH}/tao/x11)
set(DANCEX11_BASE_PATH ${SOURCE_PATH}/dancex11)
set(DANCEX11_SOURCE_PATH ${DANCEX11_BASE_PATH}/dancex11)
set(CIAOX11_BASE_PATH ${SOURCE_PATH}/ciaox11)
set(CIAOX11_SOURCE_PATH CIAOX11_BASE_PATH/ciaox11)

set(ENV{ACE_ROOT} ${ACE_ROOT})
set(ENV{TAO_ROOT} ${TAO_ROOT})
set(ENV{MPC_ROOT} ${MPC_ROOT})
set(ENV{TAOX11_ROOT} ${TAOX11_BASE_PATH})
set(ENV{CIAOX11_ROOT} ${CIAOX11_BASE_PATH})
set(ENV{DANCEX11_ROOT} ${DANCEX11_BASE_PATH})
set(ENV{SSL_ROOT} ${CURRENT_INSTALLED_DIR})
set(ENV{BZIP2_ROOT} ${CURRENT_INSTALLED_DIR})
set(ENV{ZLIB_ROOT} ${CURRENT_INSTALLED_DIR})
set(ENV{XERCESCROOT} ${CURRENT_INSTALLED_DIR})

set(BRIX11 "${SOURCE_PATH}/bin/brix11")
if(VCPKG_TARGET_IS_WINDOWS)
  string(APPEND BRIX11 ".bat")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(BRIX11_STATIC_FLAG -static)
endif()

set(BITSIZE "64")
if(${VCPKG_TARGET_ARCHITECTURE} MATCHES "x86")
  set(BITSIZE "32")
endif()

vcpkg_execute_required_process(
  COMMAND ${BRIX11} configure -b ${BITSIZE} -e xerces3 -e openssl11 -W xercescroot=${CURRENT_INSTALLED_DIR} -W bzip2root=${CURRENT_INSTALLED_DIR} -W zlibroot=${CURRENT_INSTALLED_DIR} -W sslroot=${CURRENT_INSTALLED_DIR} --with=versioned_so=0
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME brix11-configure-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
  COMMAND ${BRIX11} gen build workspace.mwc ${BRIX11_STATIC_FLAG}
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME brix11-gen_build_workspace-${TARGET_TRIPLET}
)

###################################################
#
# Build
#
###################################################

if(VCPKG_TARGET_IS_WINDOWS)
	set(TARGET_PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
	if(${VCPKG_TARGET_ARCHITECTURE} MATCHES "x86")
  	set(TARGET_PLATFORM "Win32")
	endif()
  vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/workspace.sln" 
    PLATFORM ${TARGET_PLATFORM} 
    # OPTIONS /maxcpucount 
    USE_VCPKG_INTEGRATION
  )
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
  find_program(MAKE make)
  if(NOT MAKE)
    message(FATAL_ERROR "MAKE not found")
  endif()
  vcpkg_execute_build_process(
    COMMAND ${BRIX11} make --${VCPKG_BUILD_TYPE}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME brix11-make-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET}
  )
endif()

###################################################
#
#   Installation
#
###################################################


# Install include files
# Arguments:
# - SOURCE_PATH: The root path where the header, inline, and C++ source files are located.
# - SUBDIRECTORIES: A list of subdirectories under the SOURCE_PATH that contain the files to be installed.
# - INCLUDE_DIR: The destination include directory name where the files should be installed, relative to ${CURRENT_PACKAGES_DIR}/include.
function(install_includes SOURCE_PATH SUBDIRECTORIES INCLUDE_DIR)
  foreach(SUB_DIR ${SUBDIRECTORIES})
    file(GLOB INCLUDE_FILES ${SOURCE_PATH}/${SUB_DIR}/*.h ${SOURCE_PATH}/${SUB_DIR}/*.inl ${SOURCE_PATH}/${SUB_DIR}/*.cpp)
    file(COPY ${INCLUDE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${INCLUDE_DIR}/${SUB_DIR})
  endforeach()
endfunction()

set(ACE_INCLUDE_FOLDERS "." "Compression" "Compression/rle" "ETCL" "QoS" "Monitor_Control" "os_include" "os_include/arpa" "os_include/net" "os_include/netinet" "os_include/sys")
install_includes(${ACE_SOURCE_PATH} "${ACE_INCLUDE_FOLDERS}" "ace")

# Set library and DLL suffixes and prefixes
set(LIB_SUFFIX ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
set(DLL_SUFFIX ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
set(DLL_DECORATOR "")
set(LIB_DEBUG_SUFFIX "")
set(LIB_PREFIX lib)

if(VCPKG_TARGET_IS_WINDOWS)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DLL_DECORATOR s)
  endif()
  set(LIB_DEBUG_SUFFIX d)
  set(LIB_PREFIX "")
endif()

# Install libraries
# Arguments:
# - SOURCE_PATH: The path where the libraries are located
# - LIBRARIES: A list of library names to install
function(install_libraries SOURCE_PATH LIBRARIES)
  if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/lib")
      vcpkg_execute_required_process(COMMAND mkdir -p "${CURRENT_PACKAGES_DIR}/lib" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME mkdir-for-release-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
    endif()
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/")
      vcpkg_execute_required_process(COMMAND mkdir -p "${CURRENT_PACKAGES_DIR}/debug/lib/" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME mkdir-for-debug-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
    endif()
  endif()
  
  foreach(LIBRARY ${LIBRARIES})
    set(LIB_PATH ${SOURCE_PATH}/lib)

    # Install the DLL files
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
      set(RELEASE_DLL_FILE_PATH ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_SUFFIX})
      if(EXISTS ${RELEASE_DLL_FILE_PATH})
        if(VCPKG_TARGET_IS_WINDOWS)
          file(COPY ${RELEASE_DLL_FILE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        else()
          vcpkg_execute_required_process(COMMAND cp "${RELEASE_DLL_FILE_PATH}" "${CURRENT_PACKAGES_DIR}/lib/" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
        endif()
      endif()

      set(DEBUG_DLL_FILE_PATH ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${LIB_DEBUG_SUFFIX}${DLL_SUFFIX})
      if(EXISTS ${DEBUG_DLL_FILE_PATH})
        if(VCPKG_TARGET_IS_WINDOWS)
          file(COPY ${DEBUG_DLL_FILE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        else()
          vcpkg_execute_required_process(COMMAND cp "${DEBUG_DLL_FILE_PATH}" "${CURRENT_PACKAGES_DIR}/debug/lib/" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
        endif()
      endif()
    endif()

    # Install the lib files
    set(RELEASE_LIB_FILE_PATH ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_SUFFIX})
    if(EXISTS ${RELEASE_LIB_FILE_PATH})
      if(VCPKG_TARGET_IS_WINDOWS)
        file(COPY ${RELEASE_LIB_FILE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
      else()        
        vcpkg_execute_required_process(COMMAND cp "${RELEASE_LIB_FILE_PATH}" "${CURRENT_PACKAGES_DIR}/lib/" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
      endif()
    endif()

    set(DEBUG_LIB_FILE_PATH ${LIB_PATH}/${LIB_PREFIX}${LIBRARY}${DLL_DECORATOR}${LIB_DEBUG_SUFFIX}${LIB_SUFFIX})
    if(EXISTS ${DEBUG_LIB_FILE_PATH})
      if(VCPKG_TARGET_IS_WINDOWS)
        file(COPY ${DEBUG_LIB_FILE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
      else()        
        vcpkg_execute_required_process(COMMAND cp "${DEBUG_LIB_FILE_PATH}" "${CURRENT_PACKAGES_DIR}/debug/lib/" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
      endif()
    endif()
  endforeach()
endfunction()


set(BUILD_TAO 1)
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

set(BUILD_TAOX11 1)
if(BUILD_TAOX11)
  set(TAOX11_INCLUDE_FOLDERS "." "anytypecode" "bidir_giop" "codecfactory" "dynamic_any" "ext" "ifr_client" "ior_interceptor" "ior_table" "logger" 
                             "messaging" "ort" "pi" "pi_server" "portable_server" "typecodefactory" "valuetype")
  install_includes(${TAOX11_SOURCE_PATH} "${TAOX11_INCLUDE_FOLDERS}" "tao/x11")
  
  set(TAOX11_ORBSVCS_INCLUDE_FOLDERS "naming_server")
  install_includes(${TAOX11_BASE_PATH}/orbsvcs/orbsvcs "${TAOX11_ORBSVCS_INCLUDE_FOLDERS}" "orbsvcs")
  
endif()

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

set(TAOX11_LIBRARIES "taox11" "taox11_anytypecode" "taox11_bidir_giop" "taox11_codecfactory" "taox11_cosnaming_skel" 
                     "taox11_cosnaming_stub" "taox11_dynamicany" "taox11_ifr_client_skel" "taox11_ifr_client_stub" 
                     "taox11_ior_interceptor" "taox11_ior_table" "taox11_messaging" "taox11_ort" "taox11_pi" 
                     "taox11_pi_server" "taox11_portable_server" "taox11_typecodefactory" "taox11_valuetype" 
                     "x11_logger")
install_libraries(${SOURCE_PATH} "${TAOX11_LIBRARIES}")

set(DANCEX11_LIBRARIES "dancex11_applicationmanager_skel" "dancex11_applicationmanager_stub" "dancex11_artifact_deployment_handler" 
                       "dancex11_artifact_installation" "dancex11_artifactinstallation_stub" "dancex11_cdr_plan_loader" "dancex11_convert_plan" 
                       "dancex11_deployment_ami_stub" "dancex11_deployment_configurator" "dancex11_deployment_handler" "dancex11_deployment_scheduler" 
                       "dancex11_deployment_skel" "dancex11_deployment_stub" "dancex11_deploymentmanagerhandler_skel" 
                       "dancex11_deploymentmanagerhandler_stub" "dancex11_domain_dm_handler" "dancex11_domainapplication_skel" 
                       "dancex11_domainapplication_stub" "dancex11_domainapplicationmanager_skel" "dancex11_domainapplicationmanager_stub" 
                       "dancex11_error_interceptors" "dancex11_executionmanager_impl" "dancex11_executionmanager_skel" "dancex11_executionmanager_stub" 
                       "dancex11_file_installation" "dancex11_http_installation" "dancex11_installation_repository_manager" 
                       "dancex11_locality_configuration" "dancex11_locality_dm_handler" "dancex11_locality_handler" "dancex11_localitymanager_skel" 
                       "dancex11_localitymanager_stub" "dancex11_logger" "dancex11_node_deployment_ami_stub" "dancex11_node_dm_handler" 
                       "dancex11_nodeapplication_skel" "dancex11_nodeapplication_stub" "dancex11_nodeapplicationmanager_skel" 
                       "dancex11_nodeapplicationmanager_stub" "dancex11_nodemanager_impl" "dancex11_nodemanager_skel" "dancex11_nodemanager_stub" 
                       "dancex11_plan_loader" "dancex11_split_plan" "dancex11_state" "dancex11_stub" "dancex11_targetmanager_skel")
install_libraries(${DANCEX11_BASE_PATH} "${DANCEX11_LIBRARIES}")

set(CIAOX11_LIBRARIES "ciaox11_ami4ccm_impl" "ciaox11_ami4ccm_stub" "ciaox11_ccm_session_stub" "ciaox11_ccm_stub" "ciaox11_ccmobject_skel"
                      "ciaox11_ccmobject_stub" "ciaox11_config_stub" "ciaox11_corba4ccm_impl" "ciaox11_corba_util" "ciaox11_core"
                      "ciaox11_deployment_handlers" "ciaox11_deployment_interceptors" "ciaox11_deployment_state" "ciaox11_exf_amh_base"
                      "ciaox11_exf_core" "ciaox11_exf_deployment_handlers" "ciaox11_exf_logger" "ciaox11_exf_monitor" "ciaox11_exf_scheduler"
                      "ciaox11_logger" "ciaox11_tt4ccm_conn" "ciaox11_tt4ccm_exf_conn" "ciaox11_tt4ccm_stub" "tt4ccm_conn_stub")
install_libraries(${CIAOX11_BASE_PATH} "${CIAOX11_LIBRARIES}")

# install idl compiler(s)

if(BUILD_TAO) 
  if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
      file(COPY ${ACE_ROOT}/lib/${LIB_PREFIX}ACE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
      file(COPY ${ACE_ROOT}/lib/${LIB_PREFIX}TAO_IDL_FE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
      file(COPY ${ACE_ROOT}/lib/${LIB_PREFIX}TAO_IDL_BE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
    else()        
      if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
        vcpkg_execute_required_process(COMMAND mkdir -p "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-for-tools-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
      endif()
      vcpkg_execute_required_process(COMMAND cp "${ACE_ROOT}/lib/${LIB_PREFIX}ACE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
      vcpkg_execute_required_process(COMMAND cp "${ACE_ROOT}/lib/${LIB_PREFIX}TAO_IDL_FE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
      vcpkg_execute_required_process(COMMAND cp "${ACE_ROOT}/lib/${LIB_PREFIX}TAO_IDL_BE${LIB_DEBUG_SUFFIX}${DLL_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-libs-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
    endif()
  endif()
  if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${ACE_ROOT}/bin/tao_idl${VCPKG_TARGET_EXECUTABLE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
  else()        
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
        vcpkg_execute_required_process(COMMAND mkdir -p "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME mkdir-for-tools-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
    endif()
    vcpkg_execute_required_process(COMMAND cp "${ACE_ROOT}/bin/tao_idl${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" WORKING_DIRECTORY ${SOURCE_PATH} LOGNAME copy-tao_idl-${VCPKG_BUILD_TYPE}-${TARGET_TRIPLET})
  endif()
endif()

if(BUILD_TAOX11)
  if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${SOURCE_PATH}/bin/ridlc.bat DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/)
  endif()
  file(COPY ${SOURCE_PATH}/bin/ridlc DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/)
  file(COPY ${SOURCE_PATH}/.ridlrc DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
  file(COPY ${SOURCE_PATH}/ridl/bin DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/ridl/)
  file(COPY ${SOURCE_PATH}/ridl/lib DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/ridl/)
  file(COPY ${SOURCE_PATH}/ridl/rakelib DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/ridl/)
  file(COPY ${SOURCE_PATH}/ridl/ridlbe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/ridl/)
  file(COPY ${SOURCE_PATH}/ridl/Rakefile DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/ridl/)
  file(COPY ${SOURCE_PATH}/taox11/ridlbe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/taox11/)
  file(COPY ${SOURCE_PATH}/taox11/tao/x11/versionx11.h DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/taox11/tao/x11/)
endif()


# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()

