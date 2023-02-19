project(nodelib)

add_custom_target(nodelib_def ALL
    COMMAND ${NODEJS_EXECUTABLE} ${CMAKE_SOURCE_DIR}/generateNodeLibDef.js
    COMMENT "Generating .def file"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(nodelib ALL
    COMMAND ${CMAKE_AR}
    /def:${CMAKE_SOURCE_DIR}/node.def
    /out:${CMAKE_BINARY_DIR}/node.lib
    ${CMAKE_STATIC_LINKER_FLAGS}
    DEPENDS ${CMAKE_JS_NODELIB_DEF}
    COMMENT "Building node.lib"
)

add_dependencies(nodelib nodelib_def)

install(FILES ${CMAKE_BINARY_DIR}/node.lib DESTINATION lib)