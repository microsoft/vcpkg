FIND_PROGRAM( TAO_IDL_COMMAND tao_idl )

MACRO( APPEND orig_string new_string )
  IF( NOT ${orig_string} )
    SET( ${orig_string} ${new_string} )
  ELSE( NOT ${orig_string} )
    SET( ${orig_string} ${${orig_string}} ${new_string} )
  ENDIF( NOT ${orig_string} )
ENDMACRO( APPEND orig_string new_string )

MACRO( GENERATE_TAO_IDL_RULES generated_client_sources generated_client_headers generated_client_inlines generated_server_sources generated_server_headers)
  FOREACH( idl_source ${ARGN} )
    STRING( REGEX REPLACE "\\.idl" C.cpp client_source_output ${idl_source} )
    STRING( REGEX REPLACE "\\.idl" C.h   client_header_output ${idl_source} )
    STRING( REGEX REPLACE "\\.idl" C.inl   client_inline_output ${idl_source} )
    STRING( REGEX REPLACE "\\.idl" S.cpp server_source_output ${idl_source} )
    STRING( REGEX REPLACE "\\.idl" S.h   server_header_output ${idl_source} )

    ADD_CUSTOM_COMMAND(
      OUTPUT ${client_source_output} ${client_header_output} ${server_source_output} ${server_header_output}
      COMMAND ${TAO_IDL_COMMAND}
      ARGS ${TAO_IDL_ARGS} ${CMAKE_CURRENT_SOURCE_DIR}/${idl_source}
      DEPENDS ${idl_source}
      COMMENT "Generating ${client_source_output}, ${client_header_output}, ${client_inline_output}, ${server_source_output}, ${server_header_output} from ${idl_source}"
    )

    list(APPEND ${generated_client_sources} ${CMAKE_CURRENT_BINARY_DIR}/${client_source_output})
    list(APPEND ${generated_client_headers} ${CMAKE_CURRENT_BINARY_DIR}/${client_header_output})
    list(APPEND ${generated_client_inlines} ${CMAKE_CURRENT_BINARY_DIR}/${client_inline_output})
    list(APPEND ${generated_server_sources} ${CMAKE_CURRENT_BINARY_DIR}/${server_source_output})
    list(APPEND ${generated_server_headers} ${CMAKE_CURRENT_BINARY_DIR}/${server_header_output})

  ENDFOREACH( idl_source ${ARGN} )
ENDMACRO( GENERATE_TAO_IDL_RULES generated_client_sources generated_client_headers generated_server_sources generated_server_headers )
