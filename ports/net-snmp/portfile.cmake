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

set(NET_SNMP_FEATURE_LIST "")
list(APPEND NET_SNMP_FEATURE_LIST "--with-sdk")    
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=static")    
else()
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=dynamic")    
endif()

set(TARGET_DIR "${CURRENT_PACKAGES_DIR}")
set(TARGET_DIR_DEBUG "${CURRENT_PACKAGES_DIR}/debug")

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
    PRERUN_SHELL_RELEASE "${PERL}" Configure ${NET_SNMP_FEATURE_LIST} --config=release --prefix=${TARGET_DIR}
    PRERUN_SHELL_DEBUG "${PERL}" Configure ${NET_SNMP_FEATURE_LIST} --config=debug --prefix=${TARGET_DIR_DEBUG}
    PROJECT_NAME "Makefile"
    TARGET ${TARGETS} install install_devel
    LOGFILE_ROOT build-net-snmp
)

# remove not needed files
file(REMOVE
    "${TARGET_DIR}/bin/mib2c"
    "${TARGET_DIR}/bin/mib2c.bat"
    "${TARGET_DIR}/bin/snmpconf"
    "${TARGET_DIR}/bin/snmpconf.bat"
    "${TARGET_DIR}/bin/traptoemail"
    "${TARGET_DIR}/bin/traptoemail.bat"
    "${TARGET_DIR_DEBUG}/bin/mib2c"
    "${TARGET_DIR_DEBUG}/bin/mib2c.bat"
    "${TARGET_DIR_DEBUG}/bin/snmpconf"
    "${TARGET_DIR_DEBUG}/bin/snmpconf.bat"
    "${TARGET_DIR_DEBUG}/bin/traptoemail"
    "${TARGET_DIR_DEBUG}/bin/traptoemail.bat"
    )

file(REMOVE_RECURSE
    "${TARGET_DIR}/etc"
    "${TARGET_DIR}/temp"
    "${TARGET_DIR}/snmp"
    "${TARGET_DIR_DEBUG}/etc"
    "${TARGET_DIR_DEBUG}/temp"
    "${TARGET_DIR_DEBUG}/snmp"
)

file(GLOB LIB_FILES
    LIST_DIRECTORIES false
    "${TARGET_DIR}/lib/release/*")

if(LIB_FILES)
    file(MAKE_DIRECTORY "${TARGET_DIR}/lib")
    file(COPY ${LIB_FILES} DESTINATION "${TARGET_DIR}/lib")
endif()

file(GLOB LIB_FILES_DEBUG
     LIST_DIRECTORIES false
     "${TARGET_DIR_DEBUG}/lib/debug/*")

if(LIB_FILES_DEBUG)
    file(MAKE_DIRECTORY "${TARGET_DIR_DEBUG}/lib")
    file(COPY ${LIB_FILES_DEBUG} DESTINATION "${TARGET_DIR_DEBUG}/lib")
endif()

file(REMOVE
    "${TARGET_DIR}/include/net-snmp/net-snmp-config.h"
    "${TARGET_DIR}/lib/netsnmp.exp"
)

file(REMOVE_RECURSE 
    "${TARGET_DIR_DEBUG}/include"
    "${TARGET_DIR_DEBUG}/share"
)

file(INSTALL
    "${TARGET_DIR}/"
    DESTINATION
    "${CURRENT_PACKAGES_DIR}"
)

file(INSTALL
    "${TARGET_DIR_DEBUG}/"
    DESTINATION
    "${CURRENT_PACKAGES_DIR}/debug"
)

if ("tools" IN_LIST FEATURES) 
    vcpkg_copy_tools(
        TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
        SEARCH_DIR "${TARGET_DIR}/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools"
        AUTO_CLEAN
    )
endif()


vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()