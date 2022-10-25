# This include guard ensures the file will be loaded only once
include_guard(GLOBAL)

function(vcpkg_add_ts_parser)
  cmake_parse_arguments(PARSER
    ""
    ""
    "LANGUAGE;VERSION;MIN_ABI_VERSION;SOURCE_PATH;LICENSE_FILE" ${ARGN})

  set(PARSER_NAME tree-sitter-${PARSER_LANGUAGE})

  if(NOT PARSER_VERSION)
    # https://docs.fedoraproject.org/en-US/packaging-guidelines/Versioning/#_upstream_has_never_chosen_a_version
    set(PARSER_VERSION 0)
  endif()

  if(EXISTS "${PARSER_SOURCE_PATH}/src/parser.c")
    set(_abi_version_re "#define LANGUAGE_VERSION ([0-9]+)")
    file(STRINGS
      "${PARSER_SOURCE_PATH}/src/parser.c"
        _abi_version_define REGEX "${_abi_version_re}"
    )
    string(REGEX REPLACE "${_abi_version_re}" "\\1" _abi_version ${_abi_version_define})
  endif()

  if(NOT PARSER_MIN_ABI_VERSION)
    message(STATUS "[NOTICE] To use a different minimum ABI-version for this parser, create an overlay port, and set MIN_ABI_VERSION.")
    message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
    message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")
  endif()

  if(NOT _abi_version EQUAL PARSER_MIN_ABI_VERSION)
    message(FATAL_ERROR "ABI mismatch with ${PARSER_NAME}, expected ${PARSER_MIN_ABI_VERSION}.")
  endif()

  if(NOT PARSER_LICENSE_FILE)
    set(PARSER_LICENSE_FILE "${PARSER_SOURCE_PATH}/LICENSE")
  endif()

  configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/tree-sitter-common/CMakeLists.txt.in" "${PARSER_SOURCE_PATH}/CMakeLists.txt" @ONLY)
  configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/tree-sitter-common/parser.h.in" "${PARSER_SOURCE_PATH}/${PARSER_NAME}.h.in" COPYONLY)
  configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/tree-sitter-common/parser.pc.in" "${PARSER_SOURCE_PATH}/${PARSER_NAME}.pc.in" COPYONLY)

  vcpkg_cmake_configure(
    SOURCE_PATH "${PARSER_SOURCE_PATH}"
  )

  vcpkg_build_cmake()

  vcpkg_install_cmake()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
  endif()

  # Handle copyright
  file(INSTALL "${PARSER_LICENSE_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

  vcpkg_copy_pdbs()
endfunction()
