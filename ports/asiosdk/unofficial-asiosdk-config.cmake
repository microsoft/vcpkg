if(NOT WIN32)
  message(FATAL_ERROR "unofficial-asiosdk-config.cmake: Unsupported platform ${CMAKE_SYSTEM_NAME}")
endif()

if(NOT TARGET unofficial::asiosdk::host)
  find_path(asiosdk_ROOT_DIR asiosdk REQUIRED)
  set(asiosdk_ROOT_DIR "${asiosdk_ROOT_DIR}/asiosdk")

  add_library(unofficial::asiosdk::host INTERFACE IMPORTED)

  target_sources(unofficial::asiosdk::host INTERFACE
    "${asiosdk_ROOT_DIR}/common/asio.cpp"
    "${asiosdk_ROOT_DIR}/host/asiodrivers.cpp"
    "${asiosdk_ROOT_DIR}/host/pc/asiolist.cpp"
  )

  target_include_directories(unofficial::asiosdk::host INTERFACE
    "${asiosdk_ROOT_DIR}/common"
    "${asiosdk_ROOT_DIR}/host"
    "${asiosdk_ROOT_DIR}/host/pc"
  )

  target_link_libraries(unofficial::asiosdk::host INTERFACE ole32 uuid)

  unset(asiosdk_ROOT_DIR)
endif()
