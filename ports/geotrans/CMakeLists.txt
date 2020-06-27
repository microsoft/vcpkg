cmake_minimum_required(VERSION 3.10)
project(geotrans CXX)

file(GLOB_RECURSE DTCC_CPP CCS/src/dtcc/*.cpp)
include_directories(
CCS/src/dtcc 
CCS/src/dtcc/Enumerations 
CCS/src/dtcc/Exception 
CCS/src/dtcc/CoordinateSystemParameters 
CCS/src/dtcc/CoordinateSystems 
CCS/src/dtcc/CoordinateSystems/albers
CCS/src/dtcc/CoordinateSystems/bonne
CCS/src/dtcc/CoordinateSystems/datum
CCS/src/dtcc/CoordinateSystems/ellipse
CCS/src/dtcc/CoordinateSystems/geocent
CCS/src/dtcc/CoordinateSystems/grinten
CCS/src/dtcc/CoordinateSystems/mercator  
CCS/src/dtcc/CoordinateSystems/misc
CCS/src/dtcc/CoordinateSystems/nzmg
CCS/src/dtcc/CoordinateSystems/polarst
CCS/src/dtcc/CoordinateSystems/stereogr  
CCS/src/dtcc/CoordinateSystems/trcyleqa  
CCS/src/dtcc/CoordinateSystems/utm
CCS/src/dtcc/CoordinateSystems/azeq
CCS/src/dtcc/CoordinateSystems/cassini
CCS/src/dtcc/CoordinateSystems/eckert4
CCS/src/dtcc/CoordinateSystems/eqdcyl
CCS/src/dtcc/CoordinateSystems/georef
CCS/src/dtcc/CoordinateSystems/lambert
CCS/src/dtcc/CoordinateSystems/mgrs
CCS/src/dtcc/CoordinateSystems/mollweid  
CCS/src/dtcc/CoordinateSystems/omerc    
CCS/src/dtcc/CoordinateSystems/polycon   
CCS/src/dtcc/CoordinateSystems/threads   
CCS/src/dtcc/CoordinateSystems/ups       
CCS/src/dtcc/CoordinateSystems/webmerc
CCS/src/dtcc/CoordinateSystems/bng     
CCS/src/dtcc/CoordinateSystems/cyleqa   
CCS/src/dtcc/CoordinateSystems/eckert6  
CCS/src/dtcc/CoordinateSystems/gars     
CCS/src/dtcc/CoordinateSystems/gnomonic  
CCS/src/dtcc/CoordinateSystems/loccart  
CCS/src/dtcc/CoordinateSystems/miller    
CCS/src/dtcc/CoordinateSystems/neys      
CCS/src/dtcc/CoordinateSystems/orthogr  
CCS/src/dtcc/CoordinateSystems/sinusoid  
CCS/src/dtcc/CoordinateSystems/tranmerc  
CCS/src/dtcc/CoordinateSystems/usng
CCS/src/dtcc/CoordinateTuples
)
set(DTCC_INCLUDES 
include/dtcc/
include/dtcc/Enumerations 
include/dtcc/Exception 
include/dtcc/CoordinateSystemParameters 
include/dtcc/CoordinateSystems 
include/dtcc/CoordinateSystems/albers
include/dtcc/CoordinateSystems/bonne
include/dtcc/CoordinateSystems/datum
include/dtcc/CoordinateSystems/ellipse
include/dtcc/CoordinateSystems/geocent
include/dtcc/CoordinateSystems/grinten
include/dtcc/CoordinateSystems/mercator  
include/dtcc/CoordinateSystems/misc
include/dtcc/CoordinateSystems/nzmg
include/dtcc/CoordinateSystems/polarst
include/dtcc/CoordinateSystems/stereogr  
include/dtcc/CoordinateSystems/trcyleqa  
include/dtcc/CoordinateSystems/utm
include/dtcc/CoordinateSystems/azeq
include/dtcc/CoordinateSystems/cassini
include/dtcc/CoordinateSystems/eckert4
include/dtcc/CoordinateSystems/eqdcyl
include/dtcc/CoordinateSystems/georef
include/dtcc/CoordinateSystems/lambert
include/dtcc/CoordinateSystems/mgrs
include/dtcc/CoordinateSystems/mollweid  
include/dtcc/CoordinateSystems/omerc    
include/dtcc/CoordinateSystems/polycon   
include/dtcc/CoordinateSystems/threads   
include/dtcc/CoordinateSystems/ups       
include/dtcc/CoordinateSystems/webmerc
include/dtcc/CoordinateSystems/bng     
include/dtcc/CoordinateSystems/cyleqa   
include/dtcc/CoordinateSystems/eckert6  
include/dtcc/CoordinateSystems/gars     
include/dtcc/CoordinateSystems/gnomonic  
include/dtcc/CoordinateSystems/loccart  
include/dtcc/CoordinateSystems/miller    
include/dtcc/CoordinateSystems/neys      
include/dtcc/CoordinateSystems/orthogr  
include/dtcc/CoordinateSystems/sinusoid  
include/dtcc/CoordinateSystems/tranmerc  
include/dtcc/CoordinateSystems/usng
include/dtcc/CoordinateTuples
)

if(WIN32)
    add_definitions(-DLITTLE_ENDIAN)
endif()

add_library(MSPdtcc ${DTCC_CPP})
add_library(MSPCoordinateConversionService CCS/src/CoordinateConversion/CoordinateConversionService.cpp ${DTCC_CPP})

target_include_directories(MSPdtcc INTERFACE "$<INSTALL_INTERFACE:${DTCC_INCLUDES}>")
target_include_directories(MSPCoordinateConversionService INTERFACE $<INSTALL_INTERFACE:include/CoordinateConversion>)

if(WIN32)
    if (BUILD_SHARED_LIBS)
        add_definitions(
            -DMSP_CCS_EXPORTS
            -D_USRDLL
        )
    endif()
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
else()
    find_package(Threads REQUIRED)
    target_link_libraries(MSPdtcc PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()


install(
    TARGETS MSPdtcc
    EXPORT geotrans 
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    TARGETS MSPCoordinateConversionService
    EXPORT geotrans 
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY "${CMAKE_SOURCE_DIR}/CCS/src/" 
        DESTINATION "include"
        CONFIGURATIONS Release
        FILES_MATCHING 
        PATTERN "*.h" 
)

install(EXPORT geotrans NAMESPACE geotrans:: DESTINATION share/geotrans CONFIGURATIONS Release)
