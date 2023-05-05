function(lib_to_def)
    if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW OR NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        return()
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg "" "BASENAME;REGEX" "")
    if(NOT arg_BASENAME)
        message(FATAL_ERROR "BASENAME is a required argument.")
    endif()
    if(NOT arg_REGEX)
        set(arg_REGEX "[^ ]+")
    endif()

    set(logfile "${CURRENT_BUILDTREES_DIR}/dumpbin-${arg_BASENAME}-${TARGET_TRIPLET}-symbols.log")
    vcpkg_execute_required_process(
        COMMAND dumpbin /symbols "/OUT:${logfile}" "${CURRENT_PACKAGES_DIR}/lib/${arg_BASENAME}.lib"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "dumpbin-${arg_BASENAME}-${TARGET_TRIPLET}"
    )
    file(STRINGS "${logfile}" symbols REGEX "^... ........ SECT.. notype ..    External     [|] ${arg_REGEX}")
    list(TRANSFORM symbols REPLACE "^[^|]+[|] " "     ")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(REPLACE " _" " " symbols "${symbols}")
    endif()
    list(JOIN symbols "\n" symbols)
    set(symbols "EXPORTS\n${symbols}\n")
    file(READ "${CMAKE_CURRENT_LIST_DIR}/${arg_BASENAME}-${VCPKG_TARGET_ARCHITECTURE}.def" original_symbols)
    if(NOT symbols STREQUAL original_symbols)
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${arg_BASENAME}-${VCPKG_TARGET_ARCHITECTURE}.def.log" "${symbols}")
        message(SEND_ERROR "${arg_BASENAME}-${VCPKG_TARGET_ARCHITECTURE}.def has changed.")
    endif()
endfunction()
