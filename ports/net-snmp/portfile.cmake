# mingw is not supported and uwp
if(VCPKG_TARGET_IS_MINGW OR VCPKG_TARGET_IS_UWP)
    vcpkg_fail_port_install(
        MESSAGE "This port supports only desktop Windows with MSVC"
    )
endif()

# Check library linkage:
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

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

    set(NET_SNMP_FEATURE_LIST "")
    list(APPEND NET_SNMP_FEATURE_LIST "--with-sdk")    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        list(APPEND NET_SNMP_FEATURE_LIST "--linktype=static")    
    else()
        list(APPEND NET_SNMP_FEATURE_LIST "--linktype=dynamic")    
    endif()

    set(BUILD_DIR "${SOURCE_PATH}/win32/")
    if(BUILD_TYPE STREQUAL "release")
        set(TARGET_DIR "${SOURCE_PATH}/release_install")
    else()
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

    set(TARGETS "")
    if ("tools" IN_LIST FEATURES) 
        set(TARGETS all)
    else()
        set(TARGETS libs)
    endif()

    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH win32
        PRERUN_SHELL "${PERL}" Configure ${NET_SNMP_FEATURE_LIST}
        PROJECT_NAME "Makefile"
        TARGET ${TARGETS} install
        OPTIONS_RELEASE install_devel
        LOGFILE_ROOT build-${BUILD_TYPE}
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

    SET(DEST "")

    file(REMOVE
        "${TARGET_DIR}/include/net-snmp/net-snmp-config.h"
        "${TARGET_DIR}/lib/netsnmp.exp"
    )

    if(BUILD_TYPE STREQUAL "release")
        SET(DEST "${CURRENT_PACKAGES_DIR}")
    else()
        SET(DEST "${CURRENT_PACKAGES_DIR}/debug")
        #remove header
        file(REMOVE_RECURSE 
             "${TARGET_DIR}/include"
             "${TARGET_DIR}/share"
        )
    endif()

    file(INSTALL
        "${TARGET_DIR}/"
        DESTINATION
        "${DEST}"
    )

    if ("tools" IN_LIST FEATURES) 
        vcpkg_copy_tools(
            TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
            SEARCH_DIR "${TARGET_DIR}/bin"
            DESTINATION "${DEST}/tools"
            AUTO_CLEAN
        )
    endif()

endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()