project(nodelib C)

add_custom_target(nodelib ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/node.lib)
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/node.lib
  COMMAND ${NODEJS_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/generateNodeLibDef.js
  COMMAND ${CMAKE_AR}
          /def:${CMAKE_CURRENT_BINARY_DIR}/node.def
          /out:${CMAKE_CURRENT_BINARY_DIR}/node.lib
          ${CMAKE_STATIC_LINKER_FLAGS}
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/generateNodeLibDef.js
  COMMENT "Building node.lib"
)

install(FILES ${CMAKE_BINARY_DIR}/node.lib DESTINATION lib)
