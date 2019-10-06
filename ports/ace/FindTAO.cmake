set(TAO_FOUND FALSE)

find_path(TAO_INCLUDE_DIR tao/corba.h PATHS $ENV{ACE_ROOT} $ENV{TAO_ROOT} $ENV{TAO_ROOT}/include $ENV{ACE_ROOT}/include /usr/include /usr/local/include NO_DEFAULT_PATH)
find_library(TAO_LIBRARY_RELEASE NAMES TAO PATHS $ENV{ACE_ROOT}/lib /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64 NO_DEFAULT_PATH)
find_library(TAO_LIBRARY_DEBUG NAMES TAOd PATHS $ENV{ACE_ROOT}/lib /debug/lib /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64 NO_DEFAULT_PATH)
find_program(TAO_IDL_COMPILER "tao_idl" /usr/bin $ENV{TAO_ROOT}/bin $ENV{ACE_ROOT}/bin /usr/bin /usr/local/bin /tools/ace-tao NO_DEFAULT_PATH)
message(STATUS "tao_idl at: ${TAO_IDL_COMPILER}")

if(TAO_INCLUDE_DIR AND TAO_LIBRARY_RELEASE AND TAO_IDL_COMPILER)
  SET(TAO_FOUND TRUE)
endif(TAO_INCLUDE_DIR AND TAO_LIBRARY_RELEASE AND TAO_IDL_COMPILER)
#now let's search for parts of tao we need.

GET_FILENAME_COMPONENT(TAO_LIBRARY_RELEASE_DIR ${TAO_LIBRARY_RELEASE} PATH)
GET_FILENAME_COMPONENT(TAO_LIBRARY_DEBUG_DIR ${TAO_LIBRARY_DEBUG} PATH)

set(TAO_LIBRARIES_RELEASE ${TAO_LIBRARY_RELEASE})
set(TAO_LIBRARIES_DEBUG ${TAO_LIBRARY_DEBUG})


if(TAO_FOUND)
	set(TAO_FIND_LIBS "AnyTypeCode" "Async_ImR_Client_IDL"
    "Async_IORTable" "AV" "BiDirGIOP" "Bzip2Compressor" "Catior_i" "CodecFactory" "Codeset" 
    "Compression" "CosConcurrency" "CosConcurrency_Serv" "CosConcurrency_Skel" "CosEvent"
    "CosEvent_Serv"  "CosEvent_Skel" "CosLifeCycle" "CosLifeCycle_Skel" "CosLoadBalancing"
    "CosNaming" "CosNaming_Serv" "CosNaming_Skel" "CosNotification" "CosNotification_MC"
    "CosNotification_MC_Ext"
    "CosNotification_Serv" "CosNotification_Skel" "CosNotification_Persist" "CosProperty"
    "CosProperty_Serv" "CosProperty_Skel" "CosTime" "CosTime_Serv" "CosTrading"
    "CosTrading_Serv" "CosTrading_Skel" "CSD_Framework" "CSD_ThreadPool" "DiffServPolicy"
    "DsEventLogAdmin" "DsEventLogAdmin_Serv" "DsEventLogAdmin_Skel" "DsLogAdmin"
    "DsLogAdmin_Serv" "DsLogAdmin_Skel" "DsNotifyLogAdmin" "DsNotifyLogAdmin_Serv"
    "DsNotifyLogAdmin_Skel" "Dynamic_TP" "DynamicAny" "DynamicInterface" "EndpointPolicy"
    "ETCL" "FT_Naming_Serv" "FT_ServerORB" "FtNaming" "FtNamingReplication" 
    "FTORB_Utils" "FTRT_ClientORB" "FTRT_EventChannel" "FtRtEvent" "HTIOP" "IDL_BE"
    "IDL_FE" "IFR_BE" "IFR_Client" "IFR_Client_skel" "ImR_Activator_IDL" "ImR_Client"
    "ImR_Locator_IDL" "IORInterceptor" "IORManip" "IORTable" "Messaging" "Monitor"
    "Notify_Service" "ObjRefTemplate" "PI" "PI_Server" "PortableGroup" "PortableServer" "QtResource"
    "ReplicationManagerLib" "RLECompressor" "RT_Notification" "RTCORBA" "RTEvent" "RTEvent_Skel"
    "RTKokyuEvent" "RTEventLogAdmin" "RTEventLogAdmin_Skel" "RTPortableServer" "RTSched" "RTScheduler"
    "Security" "SmartProxies"  "Strategies" "Svc_Utils" "TC" "TC_IIOP"
    "TypeCodeFactory" "Utils" "Valuetype" "ZIOP" "SSLIOP" 
    "ZlibCompressor")
    
    message("Finding TAO libraries...")
		
	if(WIN32)
		message(STATUS "TAO release found at: ${TAO_LIBRARY_RELEASE}")
		message(STATUS "TAO debug found at: ${TAO_LIBRARY_DEBUG}")
		set(TAO_LIBRARY optimized ${TAO_LIBRARY_RELEASE} debug ${TAO_LIBRARY_DEBUG})
	else(WIN32)
		message(STATUS "TAO found at: ${TAO_LIBRARY_RELEASE}")
		set(TAO_LIBRARY ${TAO_LIBRARY_RELEASE})
	endif(WIN32)
    foreach(LIBRARY ${TAO_FIND_LIBS})
	    if(WIN32)
		    find_library(TAO_${LIBRARY}_LIBRARY_DEBUG NAMES "TAO_${LIBRARY}d" PATHS ${TAO_LIBRARY_DEBUG_DIR} NO_DEFAULT_PATH)
		    if(TAO_${LIBRARY}_LIBRARY_DEBUG)
			    message(STATUS "${LIBRARY} debug found at: ${TAO_${LIBRARY}_LIBRARY_DEBUG}")
    	        list(APPEND TAO_LIBRARIES_DEBUG ${TAO_${LIBRARY}_LIBRARY_DEBUG})
		    else(TAO_${LIBRARY}_LIBRARY_DEBUG)
		        set(TAO_FOUND FALSE)
		    endif(TAO_${LIBRARY}_LIBRARY_DEBUG)
		endif(WIN32)
        find_library(TAO_${LIBRARY}_LIBRARY_RELEASE NAMES "TAO_${LIBRARY}" ${TAO_LIBRARY} PATHS ${TAO_LIBRARY_RELEASE_DIR} NO_DEFAULT_PATH)
        if(TAO_${LIBRARY}_LIBRARY_RELEASE)
            if(WIN32)
                message(STATUS "${LIBRARY} release found at: ${TAO_${LIBRARY}_LIBRARY_RELEASE}")
            else(WIN32)
                message(STATUS "${LIBRARY} found at: ${TAO_${LIBRARY}_LIBRARY_RELEASE}")
            endif(WIN32)
          list(APPEND TAO_LIBRARIES_RELEASE ${TAO_${LIBRARY}_LIBRARY_RELEASE})
        else(TAO_${LIBRARY}_LIBRARY_RELEASE)
          set(TAO_FOUND FALSE)
        endif(TAO_${LIBRARY}_LIBRARY_RELEASE)

        if(WIN32)
            set(TAO_${LIBRARY}_LIBRARY optimized ${TAO_${LIBRARY}_LIBRARY_RELEASE} debug ${TAO_${LIBRARY}_LIBRARY_DEBUG})
        else(WIN32)
            set(TAO_${LIBRARY}_LIBRARY ${TAO_${LIBRARY}_LIBRARY_RELEASE})
        endif(WIN32)
    endforeach()
endif(TAO_FOUND)


