cmake_minimum_required(VERSION 3.12.0)

set(PROJECT_VERSION "0.4.3")
project(winpty VERSION ${PROJECT_VERSION} LANGUAGES CXX)

add_definitions(-DPROJECT_VERSION="${PROJECT_VERSION}")
add_definitions(-D_WIN32_WINNT=0x0600)
add_definitions(-DUNICODE)
add_definitions(-D_UNICODE)
add_definitions(-DNOMINMAX)

if("${BUILD_TYPE}" STREQUAL "STATIC")
    add_definitions(-DBUILD_STATIC)
else()
    add_definitions(-DCOMPILING_WINPTY_DLL)
endif()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(WINPTY_INSTALL_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include)
set(WINPTY_INSTALL_BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
set(WINPTY_INSTALL_LIB_DIR ${CMAKE_INSTALL_PREFIX}/lib)

include_directories(${WINPTY_INSTALL_INCLUDE_DIR})

#winpty library
set(WINPTYLIB_SOURCE_FILES
    src/include/winpty.h
    src/libwinpty/AgentLocation.cc
    src/libwinpty/AgentLocation.h
    src/libwinpty/winpty.cc
    src/shared/AgentMsg.h
    src/shared/BackgroundDesktop.h
    src/shared/BackgroundDesktop.cc
    src/shared/Buffer.h
    src/shared/Buffer.cc
    src/shared/DebugClient.h
    src/shared/DebugClient.cc
    src/shared/GenRandom.h
    src/shared/GenRandom.cc
    src/shared/OsModule.h
    src/shared/OwnedHandle.h
    src/shared/OwnedHandle.cc
    src/shared/StringBuilder.h
    src/shared/StringUtil.cc
    src/shared/StringUtil.h
    src/shared/WindowsSecurity.cc
    src/shared/WindowsSecurity.h
    src/shared/WindowsVersion.h
    src/shared/WindowsVersion.cc
    src/shared/WinptyAssert.h
    src/shared/WinptyAssert.cc
    src/shared/WinptyException.h
    src/shared/WinptyException.cc
    src/shared/WinptyVersion.h
    src/shared/WinptyVersion.cc
    src/shared/winpty_snprintf.h
)

add_library( winpty ${BUILD_TYPE} ${WINPTYLIB_SOURCE_FILES} )

#winpty agent executable
set(WINPTYAGENT_SOURCE_FILES
	src/agent/Agent.h
    src/agent/Agent.cc
    src/agent/AgentCreateDesktop.h
    src/agent/AgentCreateDesktop.cc
    src/agent/ConsoleFont.cc
    src/agent/ConsoleFont.h
    src/agent/ConsoleInput.cc
    src/agent/ConsoleInput.h
    src/agent/ConsoleInputReencoding.cc
    src/agent/ConsoleInputReencoding.h
    src/agent/ConsoleLine.cc
    src/agent/ConsoleLine.h
    src/agent/Coord.h
    src/agent/DebugShowInput.h
    src/agent/DebugShowInput.cc
    src/agent/DefaultInputMap.h
    src/agent/DefaultInputMap.cc
    src/agent/DsrSender.h
    src/agent/EventLoop.h
    src/agent/EventLoop.cc
    src/agent/InputMap.h
    src/agent/InputMap.cc
    src/agent/LargeConsoleRead.h
    src/agent/LargeConsoleRead.cc
    src/agent/NamedPipe.h
    src/agent/NamedPipe.cc
    src/agent/Scraper.h
    src/agent/Scraper.cc
    src/agent/SimplePool.h
    src/agent/SmallRect.h
    src/agent/Terminal.h
    src/agent/Terminal.cc
    src/agent/UnicodeEncoding.h
    src/agent/Win32Console.cc
    src/agent/Win32Console.h
    src/agent/Win32ConsoleBuffer.cc
    src/agent/Win32ConsoleBuffer.h
    src/agent/main.cc
    src/shared/AgentMsg.h
    src/shared/BackgroundDesktop.h
    src/shared/BackgroundDesktop.cc
    src/shared/Buffer.h
    src/shared/Buffer.cc
    src/shared/DebugClient.h
    src/shared/DebugClient.cc
    src/shared/GenRandom.h
    src/shared/GenRandom.cc
    src/shared/OsModule.h
    src/shared/OwnedHandle.h
    src/shared/OwnedHandle.cc
    src/shared/StringBuilder.h
    src/shared/StringUtil.cc
    src/shared/StringUtil.h
    src/shared/UnixCtrlChars.h
    src/shared/WindowsSecurity.cc
    src/shared/WindowsSecurity.h
    src/shared/WindowsVersion.h
    src/shared/WindowsVersion.cc
    src/shared/WinptyAssert.h
    src/shared/WinptyAssert.cc
    src/shared/WinptyException.h
    src/shared/WinptyException.cc
    src/shared/WinptyVersion.h
    src/shared/WinptyVersion.cc
    src/shared/winpty_snprintf.h
)

add_executable(winpty-agent ${WINPTYAGENT_SOURCE_FILES})
target_compile_definitions(winpty-agent PRIVATE -DWINPTY_AGENT_ASSERT)


#winpty debugserver executable
set(WINPTYAGENT_SOURCE_FILES
    src/debugserver/DebugServer.cc
    src/shared/DebugClient.h
    src/shared/DebugClient.cc
    src/shared/OwnedHandle.h
    src/shared/OwnedHandle.cc
    src/shared/OsModule.h
    src/shared/StringBuilder.h
    src/shared/StringUtil.cc
    src/shared/StringUtil.h
    src/shared/WindowsSecurity.h
    src/shared/WindowsSecurity.cc
    src/shared/WindowsVersion.h
    src/shared/WindowsVersion.cc
    src/shared/WinptyAssert.h
    src/shared/WinptyAssert.cc
    src/shared/WinptyException.h
    src/shared/WinptyException.cc
    src/shared/winpty_snprintf.h
)

add_executable(winpty-debugserver ${WINPTYAGENT_SOURCE_FILES})


if("${BUILD_TYPE}" STREQUAL "STATIC")
    install(TARGETS winpty DESTINATION ${WINPTY_INSTALL_LIB_DIR})
else()
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/winpty.dll DESTINATION ${WINPTY_INSTALL_BIN_DIR})
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/winpty.lib DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
endif()
install(TARGETS winpty-agent DESTINATION ${WINPTY_INSTALL_BIN_DIR})
install(TARGETS winpty-debugserver DESTINATION ${WINPTY_INSTALL_BIN_DIR})
install(FILES src/include/winpty.h src/include/winpty_constants.h DESTINATION ${WINPTY_INSTALL_INCLUDE_DIR})



