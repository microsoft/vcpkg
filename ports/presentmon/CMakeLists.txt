cmake_minimum_required(VERSION 3.11)
project(presentmon)

option(INSTALL_HEADERS "Install presentmon headers" ON)
option(BUILD_TOOLS "Build tool PresentMon" OFF)

set(PRESENTDATA_SRCS
    PresentData/Debug.cpp
    PresentData/GpuTrace.cpp
    PresentData/MixedRealityTraceConsumer.cpp
    PresentData/PresentMonTraceConsumer.cpp
    PresentData/TraceConsumer.cpp
    PresentData/TraceSession.cpp
)

set(PRESENTDATA_HDRS
    PresentData/Debug.hpp
    PresentData/GpuTrace.hpp
    PresentData/MixedRealityTraceConsumer.hpp
    PresentData/PresentMonTraceConsumer.hpp
    PresentData/TraceConsumer.hpp
    PresentData/TraceSession.hpp
    ${CMAKE_BINARY_DIR}/generated/version.h
)


file(GLOB EXTRA_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/PresentData/ETW/*.h)

file(WRITE ${CMAKE_BINARY_DIR}/generated/version.h "char const* PRESENT_MON_VERSION = \"1.7.0\";")

add_library(PresentData STATIC ${PRESENTDATA_SRCS} ${PRESENTDATA_HDRS} ${EXTRA_INCLUDES})

target_include_directories(PresentData PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/PresentData>
  $<INSTALL_INTERFACE:include/presentmon>
)
target_compile_definitions(PresentData PRIVATE UNICODE)

# Install targets
install(TARGETS PresentData
	RUNTIME DESTINATION bin 
	LIBRARY DESTINATION lib 
	ARCHIVE DESTINATION lib 
)

if (BUILD_TOOLS)
    set(PresentMon_SRCS
        PresentMon/CommandLine.cpp
        PresentMon/Console.cpp
        PresentMon/ConsumerThread.cpp
        PresentMon/CsvOutput.cpp
        PresentMon/LateStageReprojectionData.cpp
        PresentMon/MainThread.cpp
        PresentMon/OutputThread.cpp
        PresentMon/Privilege.cpp
        PresentMon/TraceSession.cpp
    )
    
    add_executable(PresentMon ${PresentMon_SRCS})
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
endif()
