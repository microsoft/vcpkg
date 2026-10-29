cmake_minimum_required(VERSION 3.20)
project(presentmon VERSION ${PRESENTMON_VERSION} LANGUAGES CXX)

find_package(cereal CONFIG REQUIRED)

option(INSTALL_HEADERS "Install presentmon headers" ON)
option(BUILD_TOOLS "Build tool PresentMon" OFF)

set(PRESENTDATA_SRCS
    PresentData/Debug.cpp
    PresentData/GpuTrace.cpp
    PresentData/InterPresentActivity.cpp
    PresentData/NvidiaTraceConsumer.cpp
    PresentData/PresentMonTraceConsumer.cpp
    PresentData/PresentMonTraceSession.cpp
    PresentData/TraceConsumer.cpp
    PresentData/TraceLogging.cpp
    PresentMon/LogSetup.cpp
    IntelPresentMon/CommonUtilities/Exception.cpp
    IntelPresentMon/CommonUtilities/Hash.cpp
    IntelPresentMon/CommonUtilities/Memory.cpp
    IntelPresentMon/CommonUtilities/PrecisionWaiter.cpp
    IntelPresentMon/CommonUtilities/Qpc.cpp
    IntelPresentMon/CommonUtilities/str/String.cpp
    IntelPresentMon/CommonUtilities/win/Handle.cpp
    IntelPresentMon/CommonUtilities/win/HrError.cpp
    IntelPresentMon/CommonUtilities/win/Utilities.cpp
    IntelPresentMon/CommonUtilities/win/HrErrorCodeProvider.cpp
    IntelPresentMon/CommonUtilities/log/EntryBuilder.cpp
    IntelPresentMon/CommonUtilities/log/ErrorCode.cpp
    IntelPresentMon/CommonUtilities/log/ErrorCodeResolvePolicy.cpp
    IntelPresentMon/CommonUtilities/log/ErrorCodeResolver.cpp
    IntelPresentMon/CommonUtilities/log/GlobalPolicy.cpp
    IntelPresentMon/CommonUtilities/log/IdentificationTable.cpp
    IntelPresentMon/CommonUtilities/log/Level.cpp
    IntelPresentMon/CommonUtilities/log/LinePolicy.cpp
    IntelPresentMon/CommonUtilities/log/LineTable.cpp
    IntelPresentMon/CommonUtilities/log/PanicLogger.cpp
    IntelPresentMon/CommonUtilities/log/StackTrace.cpp
    IntelPresentMon/CommonUtilities/log/Subsystem.cpp
    IntelPresentMon/CommonUtilities/log/TimePoint.cpp
    IntelPresentMon/CommonUtilities/log/Verbose.cpp
)

set(PRESENTDATA_HDRS
    PresentData/Debug.hpp
    PresentData/GpuTrace.hpp
    PresentData/InterPresentActivity.hpp
    PresentData/NvidiaTraceConsumer.hpp
    PresentData/PresentEventEnums.hpp
    PresentData/PresentMonTraceConsumer.hpp
    PresentData/PresentMonTraceSession.hpp
    PresentData/TraceConsumer.hpp
    PresentData/TraceLogging.h
    PresentData/IFilterBuildListener.h
    ${CMAKE_BINARY_DIR}/generated/version.h
)


file(GLOB EXTRA_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/PresentData/ETW/*.h)

file(WRITE ${CMAKE_BINARY_DIR}/generated/version.h "char const* PRESENT_MON_VERSION = \"${PROJECT_VERSION}\";")

add_library(PresentData STATIC ${PRESENTDATA_SRCS} ${PRESENTDATA_HDRS} ${EXTRA_INCLUDES})

target_include_directories(PresentData PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/PresentData>
  $<INSTALL_INTERFACE:include/presentmon>
)
target_compile_definitions(PresentData PRIVATE UNICODE)
target_compile_features(PresentData PUBLIC cxx_std_23)
target_include_directories(PresentData PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> PRIVATE ${CMAKE_BINARY_DIR})
target_link_libraries(PresentData PUBLIC cereal::cereal)

# Install targets
install(TARGETS PresentData
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
)

if (BUILD_TOOLS)
    enable_language(RC)
    get_filename_component(sdk_bin "${CMAKE_RC_COMPILER}" DIRECTORY)
    find_program(MESSAGE_COMPILER mc HINTS "${sdk_bin}" REQUIRED)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ddETWExternalEvents.rc"
        BYPRODUCTS
            "${CMAKE_CURRENT_BINARY_DIR}/ddETWExternalEvents.h"
            "${CMAKE_CURRENT_BINARY_DIR}/ddETWExternalEvents_MSG00001.bin"
            "${CMAKE_CURRENT_BINARY_DIR}/ddETWExternalEventsTEMP.BIN"
        COMMAND "${MESSAGE_COMPILER}" -um -z ddETWExternalEvents
            -h "${CMAKE_CURRENT_BINARY_DIR}" -r "${CMAKE_CURRENT_BINARY_DIR}"
            "${CMAKE_CURRENT_SOURCE_DIR}/PresentMon/ddETWExternal.xml"
        DEPENDS PresentMon/ddETWExternal.xml
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        VERBATIM
    )
    set(PresentMon_SRCS
        PresentMon/CommandLine.cpp
        PresentMon/Console.cpp
        PresentMon/ConsumerThread.cpp
        PresentMon/CsvOutput.cpp
        PresentMon/MainThread.cpp
        PresentMon/OutputThread.cpp
        PresentMon/Privilege.cpp
        PresentMon/PresentMon.hpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculator.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorCpuGpu.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorDisplay.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorInput.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorInstrumented.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorAnimation.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsCalculatorInterFrameEvent.cpp
        IntelPresentMon/CommonUtilities/mc/MetricsTypes.cpp
        IntelPresentMon/CommonUtilities/mc/SwapChainState.cpp
        IntelPresentMon/CommonUtilities/mc/UnifiedSwapChain.cpp
    )
    
    add_executable(PresentMon ${PresentMon_SRCS} "${CMAKE_CURRENT_BINARY_DIR}/ddETWExternalEvents.rc")
    target_include_directories(PresentMon PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/PresentMon ${CMAKE_BINARY_DIR})
    target_compile_definitions(PresentMon PRIVATE UNICODE)
    target_link_libraries(PresentMon PRIVATE PresentData Tdh Shlwapi)
    
    install(TARGETS PresentMon
        RUNTIME DESTINATION bin
    )
endif()

# Install headers
if (INSTALL_HEADERS)
  install(FILES ${PRESENTDATA_HDRS} DESTINATION include/presentmon)
  install(FILES ${EXTRA_INCLUDES} DESTINATION include/presentmon/ETW)
  set(UTILITY_HEADERS
      Exception.h Hash.h Macro.h Memory.h Meta.h PrecisionWaiter.h Qpc.h SampleStatistics.h
      log/Entry.h log/EntryBuilder.h log/ErrorCode.h log/GlobalPolicy.h log/IChannel.h
      log/IErrorCodeResolver.h log/Level.h log/Log.h log/PanicLogger.h log/StackTrace.h
      log/Subsystem.h log/TimePoint.h log/Verbose.h str/String.h win/Handle.h
  )
  foreach(header IN LISTS UTILITY_HEADERS)
    get_filename_component(header_dir "${header}" DIRECTORY)
    install(FILES "IntelPresentMon/CommonUtilities/${header}"
        DESTINATION "include/IntelPresentMon/CommonUtilities/${header_dir}")
  endforeach()
  install(FILES IntelPresentMon/PresentMonAPI2/PresentMonAPI.h DESTINATION include/IntelPresentMon/PresentMonAPI2)
endif()
