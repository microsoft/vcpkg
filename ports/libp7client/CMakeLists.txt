project(P7)
cmake_minimum_required(VERSION 3.18)

add_library(P7
  "Sources/ClBaical.cpp"
  "Sources/ClFile.cpp"
  "Sources/Client.cpp"
  "Sources/ClNull.cpp"
  "Sources/ClText.cpp"
  "Sources/CRC32.cpp"
  "Sources/Proxy.cpp"
  "Sources/Telemetry.cpp"
  "Sources/Trace.cpp")

target_include_directories(P7 PRIVATE "Headers/")
target_include_directories(P7 PRIVATE "Shared/")
if(WIN32)
  target_include_directories(P7 PRIVATE "Shared/Platforms/Windows_x86/")
  target_link_libraries(P7 "ws2_32")
else()
  target_include_directories(P7 PRIVATE "Shared/Platforms/Linux_x86/")
endif()

if(WIN32)
  set_target_properties(P7 PROPERTIES PREFIX "")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_target_properties(P7 PROPERTIES DEBUG_POSTFIX "x64d")
    set_target_properties(P7 PROPERTIES RELEASE_POSTFIX "x64")
  else()
    set_target_properties(P7 PROPERTIES DEBUG_POSTFIX "x32d")
    set_target_properties(P7 PROPERTIES RELEASE_POSTFIX "x32")
  endif()
else()
  set_target_properties(P7 PROPERTIES PREFIX "lib")
  set_target_properties(P7 PROPERTIES POSTFIX "")
  set_target_properties(P7 PROPERTIES DEBUG_POSTFIX "d")
endif()

install(TARGETS P7
        RUNTIME DESTINATION "bin"
        ARCHIVE DESTINATION "lib"
        LIBRARY DESTINATION "lib")

install(DIRECTORY Headers/
        DESTINATION include/P7
        FILES_MATCHING PATTERN "*.h")
