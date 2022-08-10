# This include guard ensures the file will be loaded only once
include_guard(GLOBAL)

function(vcpkg_ts_parser_add)
  cmake_parse_arguments(PARSER
    ""
    ""
    "LANGUAGE;MIN_ABI_VERSION;SOURCE_PATH" ${ARGN})

  if(EXISTS "${PARSER_SOURCE_PATH}/src/parser.c")
    set(_abi_version_re "#define LANGUAGE_VERSION ([0-9]+)")
    file(STRINGS
      "${PARSER_SOURCE_PATH}/src/parser.c"
        _abi_version_define REGEX "${_abi_version_re}"
    )
    string(REGEX REPLACE "${_abi_version_re}" "\\1" _abi_version ${_abi_version_define})
  endif()

  if(NOT  PARSER_MIN_ABI_VERSION)
    message(STATUS "[NOTICE] To use a different minimum ABI-version for this parser, create an overlay port, and set MIN_ABI_VERSION.")
    message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
    message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")
  endif()

  if(NOT _abi_version EQUAL PARSER_MIN_ABI_VERSION)
    message(STATUS "Re-generating parser with min ABI-version: ${PARSER_MIN_ABI_VERSION}")
    find_program(NPM NAMES npm)
    if(NOT NPM)
        message(FATAL_ERROR "node not found! Please install it via your system package manager!")
    endif()
    vcpkg_add_to_path(PREPEND "${CURRENT_BUILDTREES_DIR}/node_modules/bin")

    vcpkg_execute_required_process(
      COMMAND npm install tree-sitter-cli
      WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
      LOGNAME prerequistes-npm-${TARGET_TRIPLET}
    )
    vcpkg_execute_required_process(
      COMMAND tree-sitter generate --log --abi ${PARSER_MIN_ABI_VERSION}
      WORKING_DIRECTORY ${PARSER_SOURCE_PATH}
      LOGNAME grammar-regen-${TARGET_TRIPLET}
    )
  endif()

  set(PARSER_NAME tree-sitter-${PARSER_LANGUAGE})
  configure_file(${CURRENT_HOST_INSTALLED_DIR}/share/tree-sitter-common/CMakeLists.txt.in ${PARSER_SOURCE_PATH}/CMakeLists.txt @ONLY)

  vcpkg_cmake_configure(
    SOURCE_PATH "${PARSER_SOURCE_PATH}"
  )

  vcpkg_build_cmake()

  vcpkg_install_cmake()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
  endif()

  # Handle copyright
  file(INSTALL ${PARSER_SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

  vcpkg_fixup_pkgconfig()
  vcpkg_copy_pdbs()
endfunction()
