project ( libev C )
cmake_minimum_required ( VERSION 3.8 )

include(configure.cmake)

configure_file ( ${PROJECT_SOURCE_DIR}/config.h.cmake ${PROJECT_BINARY_DIR}/config.h )

include_directories(${PROJECT_BINARY_DIR})

file(COPY Symbols.ev DESTINATION ${PROJECT_BINARY_DIR})
file(COPY Symbols.event DESTINATION ${PROJECT_BINARY_DIR})

file(RENAME "${PROJECT_BINARY_DIR}/Symbols.ev" "${PROJECT_BINARY_DIR}/Symbols.ev.def")
file(RENAME "${PROJECT_BINARY_DIR}/Symbols.event" "${PROJECT_BINARY_DIR}/Symbols.events.def")

set(SRC
  ev.c
  event.c
  ${PROJECT_BINARY_DIR}/Symbols.events.def
  ${PROJECT_BINARY_DIR}/Symbols.ev.def
)

if (WIN32)
  list ( APPEND LIBS Ws2_32 )
endif ()

add_library ( ev ${SRC})
target_link_libraries ( ev ${LIBS} )

install(
  TARGETS ev
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
   install(FILES ev.h ev++.h event.h  DESTINATION include)
endif()
