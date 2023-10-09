cmake_minimum_required(VERSION 3.5)
project(openvpncli CXX)

find_path(ASIO_HPP asio.hpp)
find_library(MBEDTLS_LIB mbedtls)
find_library(MBEDCRYPTO_LIB mbedcrypto)
find_library(MBEDX509_LIB mbedx509)

include_directories(. ${ASIO_HPP})

if(WIN32) 
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
endif()

add_definitions(-DNOMINMAX -DUSE_ASIO -DUSE_MBEDTLS -D_WIN32_WINNT=0x0600)
if(LINUX)
  add_compile_options(-include bits/endian.h)
endif()

add_library(ovpncli client/ovpncli.cpp)
target_link_libraries(ovpncli PRIVATE Iphlpapi.lib Wininet.lib Setupapi.lib Cfgmgr32.lib Rpcrt4.lib Fwpuclnt.lib Wtsapi32.lib ${MBEDTLS_LIB} ${MBEDCRYPTO_LIB} ${MBEDX509_LIB})

target_include_directories(ovpncli PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

install(
    TARGETS ovpncli
    EXPORT unofficial-openvpnConfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

INSTALL(EXPORT unofficial-openvpnConfig
    NAMESPACE unofficial::openvpn3::
    DESTINATION share/unofficial-openvpn
)

if(BUILD_TOOL)
    add_executable(cli test/ovpncli/cli.cpp)
    target_compile_definitions(cli PRIVATE -DTAP_WIN_COMPONENT_ID=tap0901)
    target_link_libraries(cli PRIVATE ovpncli)    
endif()
