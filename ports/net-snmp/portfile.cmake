set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/net-snmp/net-snmp/archive/refs/tags/v${VERSION}.tar.gz"
    FILENAME "v${VERSION}.tar.gz"
    SHA512 0a62a1d263437409cf50e20da7f82132cc3df9a7ecf9e1d57ac00285199617b168636e4a042cd564fcb1b8417883e618238ca252066b9e6e77c4c9030026ff30
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Acquire Perl and add it to PATH (for execution of Configure)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_PATH}")

list(APPEND NET_SNMP_FEATURE_LIST "--with-sdk")    

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=static")    
else()
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=dynamic")    
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set (BUILD_TYPE "release")
    list(APPEND NET_SNMP_FEATURE_LIST "--config=release")
    set(BUILD_DIR "${SOURCE_PATH}/win32-release")
    if(NOT EXISTS "${BUILD_DIR}")
        file(COPY "${SOURCE_PATH}/win32/" DESTINATION "${BUILD_DIR}")
    endif()
else()
    set (BUILD_TYPE "debug")
    list(APPEND NET_SNMP_FEATURE_LIST "--config=debug")
    set(BUILD_DIR "${SOURCE_PATH}/win32-debug")
    if(NOT EXISTS "${BUILD_DIR}")
        file(COPY "${SOURCE_PATH}/win32/" DESTINATION "${BUILD_DIR}")
    endif()
endif()

message(STATUS "Build type: ${BUILD_TYPE}")
message(STATUS "Configure options: ${NET_SNMP_FEATURE_LIST}")

vcpkg_execute_build_process(
    COMMAND ${PERL} Configure ${NET_SNMP_FEATURE_LIST}
    WORKING_DIRECTORY ${BUILD_DIR}
    LOGNAME mwc-${TARGET_TRIPLET}
)

vcpkg_execute_build_process(
    COMMAND nmake
    WORKING_DIRECTORY ${BUILD_DIR}
    LOGNAME nmake-${TARGET_TRIPLET}
)

# ermittelt Prefix (slash-normalized) zuvor wie bei dir
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(TARGET_BIN_DIR "${CURRENT_PACKAGES_DIR}/bin")
    set(TARGET_LIB_DIR "${CURRENT_PACKAGES_DIR}/lib")
else()
    set(TARGET_BIN_DIR "${CURRENT_PACKAGES_DIR}/debug/bin")
    set(TARGET_LIB_DIR "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

# nur Dateien kopieren (keine Unterordner)
file(GLOB BIN_CANDIDATES "${BUILD_DIR}/bin/${BUILD_TYPE}/*" "${BUILD_DIR}/bin/*")
set(BIN_FILES)
foreach(_f IN LISTS BIN_CANDIDATES)
    if(NOT IS_DIRECTORY "${_f}")
        list(APPEND BIN_FILES "${_f}")
    endif()
endforeach()
if(BIN_FILES)
    file(MAKE_DIRECTORY "${TARGET_BIN_DIR}")
    file(COPY ${BIN_FILES} DESTINATION "${TARGET_BIN_DIR}")
endif()

file(GLOB LIB_CANDIDATES "${BUILD_DIR}/lib/${BUILD_TYPE}/*" "${BUILD_DIR}/lib/*")
set(LIB_FILES)
foreach(_f IN LISTS LIB_CANDIDATES)
    if(NOT IS_DIRECTORY "${_f}")
        list(APPEND LIB_FILES "${_f}")
    endif()
endforeach()
if(LIB_FILES)
    file(MAKE_DIRECTORY "${TARGET_LIB_DIR}")
    file(COPY ${LIB_FILES} DESTINATION "${TARGET_LIB_DIR}")
endif()


if(BUILD_TYPE STREQUAL "release")
    vcpkg_copy_tools(
        TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
        AUTO_CLEAN
    )
else()
    vcpkg_copy_tools(
        TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools"
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()