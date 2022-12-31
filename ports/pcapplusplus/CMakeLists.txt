cmake_minimum_required(VERSION 3.12)

project(pcapplusplus C CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

if (WIN32)
    set(BUILD_SHARED_LIBS OFF)
endif()
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS ON)

# dependencies
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)
if (WIN32)
    find_path(PCAP_INCLUDES NAMES pcap.h)
    find_library(PCAP_LIBRARY_RELEASE NAMES wpcap PATH_SUFFIXES lib REQUIRED)
    find_library(PCAP_LIBRARY_DEBUG NAMES wpcap PATH_SUFFIXES lib REQUIRED)
    find_library(PACKET_LIBRARY_RELEASE NAMES Packet PATH_SUFFIXES lib REQUIRED)
    find_library(PACKET_LIBRARY_DEBUG NAMES Packet PATH_SUFFIXES lib REQUIRED)
    select_library_configurations(PCAP)
    select_library_configurations(PACKET)
    list(APPEND PCAP_LIBRARIES ${PACKET_LIBRARIES})
else()
    find_path(PCAP_INCLUDES NAMES pcap.h)
    find_library(PCAP_LIBRARY_RELEASE NAMES pcap PATH_SUFFIXES lib REQUIRED)
    find_library(PCAP_LIBRARY_DEBUG NAMES pcap PATH_SUFFIXES lib REQUIRED)
    select_library_configurations(PCAP)
endif()

find_package(Threads REQUIRED)

# common++
file(GLOB COMMONPP_HEADERS "${CMAKE_CURRENT_LIST_DIR}/Common++/header/*.h")
file(GLOB COMMONPP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/Common++/src/*.cpp")

add_library(commonpp ${COMMONPP_SOURCES})

target_include_directories(commonpp PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Common++/header> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/EndianPortable/include> $<INSTALL_INTERFACE:include>)

set_target_properties(commonpp PROPERTIES OUTPUT_NAME Common++)
if (WIN32)
    target_compile_definitions(commonpp PRIVATE WPCAP HAVE_REMOTE _CRT_SECURE_NO_WARNINGS)
elseif (UNIX AND NOT APPLE)
    target_compile_definitions(commonpp PRIVATE LINUX)
elseif (APPLE)
    target_compile_definitions(commonpp PRIVATE MAC_OS_X)
endif()

# packet++
file(GLOB PACKETPP_HEADERS "${CMAKE_CURRENT_LIST_DIR}/Packet++/header/*.h")
file(GLOB PACKETPP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/Packet++/src/*.cpp")
list(APPEND PACKETPP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/3rdParty/hash-library/md5.cpp")

add_library(packetpp ${PACKETPP_SOURCES})

target_include_directories(packetpp PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Packet++/header> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/hash-library> $<INSTALL_INTERFACE:include>)
target_link_libraries(packetpp PRIVATE commonpp)
set_target_properties(packetpp PROPERTIES OUTPUT_NAME Packet++)
if (WIN32)
    target_compile_definitions(packetpp PRIVATE WPCAP HAVE_REMOTE _CRT_SECURE_NO_WARNINGS)
elseif (UNIX AND NOT APPLE)
    target_compile_definitions(packetpp PRIVATE LINUX)
elseif (APPLE)
    target_compile_definitions(packetpp PRIVATE MAC_OS_X)
endif()

# pcap++
file(GLOB PCAPPP_HEADERS "${CMAKE_CURRENT_LIST_DIR}/Pcap++/header/*.h")
file(GLOB PCAPPP_SOURCES "${CMAKE_CURRENT_LIST_DIR}/Pcap++/src/*.cpp")
file(GLOB LIGHTPCAPNG_SOURCES "${CMAKE_CURRENT_LIST_DIR}/3rdParty/LightPcapNg/LightPcapNg/src/*.c")

add_library(pcappp ${PCAPPP_SOURCES} ${LIGHTPCAPNG_SOURCES})

target_include_directories(pcappp PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Pcap++/header> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/LightPcapNg/LightPcapNg/include> "${PCAP_INCLUDES}" $<INSTALL_INTERFACE:include>)

target_link_libraries(pcappp PUBLIC commonpp packetpp ${PCAP_LIBRARIES} Threads::Threads)

if (WIN32)
    target_link_libraries(pcappp PUBLIC ws2_32 iphlpapi)
elseif (APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(SYSTEMCONFIGURATION_LIBRARY SystemConfiguration)
    target_link_libraries(pcappp PUBLIC ${COREFOUNDATION_LIBRARY} ${SYSTEMCONFIGURATION_LIBRARY})
endif()

if (WIN32)
    target_compile_definitions(pcappp PRIVATE WPCAP HAVE_REMOTE HAVE_STRUCT_TIMESPEC _CRT_SECURE_NO_WARNINGS)
elseif (UNIX AND NOT APPLE)
    target_compile_definitions(pcappp PRIVATE LINUX)
elseif (APPLE)
    target_compile_definitions(pcappp PRIVATE MAC_OS_X)
endif()

set_target_properties(pcappp PROPERTIES OUTPUT_NAME Pcap++)

# Install
install(FILES ${PCAPPP_HEADERS} ${COMMONPP_HEADERS} ${PACKETPP_HEADERS} DESTINATION include)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/LICENSE" DESTINATION share/pcapplusplus)

install(
  TARGETS pcappp commonpp packetpp
  EXPORT unofficial-pcapplusplus-config
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-pcapplusplus-config
  NAMESPACE unofficial::pcapplusplus::
  DESTINATION share/unofficial-pcapplusplus
)
