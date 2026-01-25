if(VCPKG_TARGET_IS_MINGW)
    vcpkg_fail_port_install(
        MESSAGE "net-snmp supports only the MSVC toolchain"
    )
endif()

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

if (NOT DEFINED VCPKG_BUILD_TYPE)
    list(APPEND BUILD_TYPES "release")
    list(APPEND BUILD_TYPES "debug")
elseif(VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND BUILD_TYPES "release")
elseif(VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND BUILD_TYPES "debug")
endif()

foreach(BUILD_TYPE ${BUILD_TYPES})

    set(SET NET_SNMP_FEATURE_LIST)
    list(APPEND NET_SNMP_FEATURE_LIST "--with-sdk")    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        list(APPEND NET_SNMP_FEATURE_LIST "--linktype=static")    
    else()
        list(APPEND NET_SNMP_FEATURE_LIST "--linktype=dynamic")    
    endif()

    set(BUILD_DIR "${SOURCE_PATH}/win32/")
    if(BUILD_TYPE STREQUAL "release")
        #set(BUILD_DIR "${SOURCE_PATH}/win32-release")
        #if(NOT EXISTS "${BUILD_DIR}")
        #    file(COPY "${SOURCE_PATH}/win32/" DESTINATION "${BUILD_DIR}")
        #endif()
        set(TARGET_DIR "${SOURCE_PATH}/release_install")
    else()
        #set(BUILD_DIR "${SOURCE_PATH}/win32-debug")
        #if(NOT EXISTS "${BUILD_DIR}")
        #    file(COPY "${SOURCE_PATH}/win32/" DESTINATION "${BUILD_DIR}")
        #endif()
        set(TARGET_DIR "${SOURCE_PATH}/debug_install")
    endif()

    list(APPEND NET_SNMP_FEATURE_LIST "--config=${BUILD_TYPE}")
    list(APPEND NET_SNMP_FEATURE_LIST "--prefix=${TARGET_DIR}")

    if("ssl" IN_LIST FEATURES)
        list(APPEND NET_SNMP_FEATURE_LIST "--with-ssl")    
        list(APPEND NET_SNMP_FEATURE_LIST "--with-sslincdir=${CURRENT_INSTALLED_DIR}/include")    
        list(APPEND NET_SNMP_FEATURE_LIST "--with-ssllibdir=${CURRENT_INSTALLED_DIR}/lib")    
    endif()

    list(JOIN NET_SNMP_FEATURE_LIST " " NET_SNMP_FEATURES)
    message(INFO " active features:${NET_SNMP_FEATURES}")

    vcpkg_execute_build_process(
        COMMAND ${PERL} Configure ${NET_SNMP_FEATURE_LIST}
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME mwc-${TARGET_TRIPLET}
    )

    vcpkg_execute_build_process(
        COMMAND nmake
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME build-${TARGET_TRIPLET}
    )

    vcpkg_execute_build_process(
        COMMAND nmake libs
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME install-${TARGET_TRIPLET}
    )

    vcpkg_execute_build_process(
        COMMAND nmake install
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME install-${TARGET_TRIPLET}
    )

    vcpkg_execute_build_process(
        COMMAND nmake install_devel
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME install-${TARGET_TRIPLET}
    )

    # remove not needed files
    file(REMOVE
        "${TARGET_DIR}/bin/mib2c"
        "${TARGET_DIR}/bin/mib2c.bat"
        "${TARGET_DIR}/bin/snmpconf"
        "${TARGET_DIR}/bin/snmpconf.bat"
        "${TARGET_DIR}/bin/traptoemail"
        "${TARGET_DIR}/bin/traptoemail.bat")

    file(REMOVE_RECURSE
        "${TARGET_DIR}/etc"
        "${TARGET_DIR}/temp"
        "${TARGET_DIR}/snmp"
    )

    file(GLOB LIB_CANDIDATES "${BUILD_DIR}/lib/${BUILD_TYPE}/*")
    set(LIB_FILES)
    foreach(_f IN LISTS LIB_CANDIDATES)
        if(NOT IS_DIRECTORY "${_f}")
            list(APPEND LIB_FILES "${_f}")
        endif()
    endforeach()
    if(LIB_FILES)
        file(MAKE_DIRECTORY "${TARGET_DIR}/lib")
        file(COPY ${LIB_FILES} DESTINATION "${TARGET_DIR}/lib")
    endif()

    

    if(BUILD_TYPE STREQUAL "release")
        file(REMOVE
             "${TARGET_DIR}/include/net-snmp/net-snmp-config.h"
             "${TARGET_DIR}/lib/netsnmp.exp"
        )

        file(INSTALL
             "${TARGET_DIR}/"
             DESTINATION
             "${CURRENT_PACKAGES_DIR}"
        )

        vcpkg_copy_tools(
            TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
            AUTO_CLEAN
        )
    else()
        #remove header
        file(REMOVE_RECURSE 
             "${TARGET_DIR}/include"
             "${TARGET_DIR}/share"
             "${TARGET_DIR}/lib/netsnmp.exp"
        )

        file(INSTALL
            "${TARGET_DIR}/"
            DESTINATION
            "${CURRENT_PACKAGES_DIR}/debug"
        )
        vcpkg_copy_tools(
            TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
            SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools"
            AUTO_CLEAN
        )
    endif()

endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()