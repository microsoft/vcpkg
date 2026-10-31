vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO net-snmp/net-snmp
    REF "v${VERSION}"
    SHA512 0a62a1d263437409cf50e20da7f82132cc3df9a7ecf9e1d57ac00285199617b168636e4a042cd564fcb1b8417883e618238ca252066b9e6e77c4c9030026ff30
    PATCHES
        fix-win32-build.patch
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

set(NET_SNMP_SSL "")
set(NET_SNMP_SSL_DEBUG "")

if("ssl" IN_LIST FEATURES)
    list(APPEND NET_SNMP_SSL "--with-ssl" "--with-sslincdir=${CURRENT_INSTALLED_DIR}/include" "--with-ssllibdir=${CURRENT_INSTALLED_DIR}/lib")
    list(APPEND NET_SNMP_SSL_DEBUG "--with-ssl" "--with-sslincdir=${CURRENT_INSTALLED_DIR}/include" "--with-ssllibdir=${CURRENT_INSTALLED_DIR}/debug/lib")
endif()

if ("tools" IN_LIST FEATURES)
    set(TARGETS all)
else()
    set(TARGETS libs)
endif()

vcpkg_build_nmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH win32
    PRERUN_SHELL_RELEASE "${PERL}" Configure
        ${NET_SNMP_FEATURE_LIST}
        ${NET_SNMP_SSL}
        --config=release
        "--prefix=${CURRENT_PACKAGES_DIR}"
    PRERUN_SHELL_DEBUG "${PERL}" Configure
        ${NET_SNMP_FEATURE_LIST}
        ${NET_SNMP_SSL_DEBUG}
        --config=debug
        "--prefix=${CURRENT_PACKAGES_DIR}/debug"
    PROJECT_NAME "Makefile"
    TARGET ${TARGETS} install install_devel
    LOGFILE_ROOT build-net-snmp
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc"
    "${CURRENT_PACKAGES_DIR}/temp"
    "${CURRENT_PACKAGES_DIR}/snmp"
)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/debug/bin/mib2c"
        "${CURRENT_PACKAGES_DIR}/debug/bin/mib2c.bat"
        "${CURRENT_PACKAGES_DIR}/debug/bin/snmpconf"
        "${CURRENT_PACKAGES_DIR}/debug/bin/snmpconf.bat"
        "${CURRENT_PACKAGES_DIR}/debug/bin/traptoemail"
        "${CURRENT_PACKAGES_DIR}/debug/bin/traptoemail.bat"
    )
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/debug/temp"
        "${CURRENT_PACKAGES_DIR}/debug/snmp"
        "${CURRENT_PACKAGES_DIR}/debug/etc"
    )
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

if("tools" IN_LIST FEATURES)
    set(NET_SNMP_TOOL_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(MAKE_DIRECTORY "${NET_SNMP_TOOL_DIR}")

    # The helper scripts shipped by net-snmp assume a Windows install layout and
    # a Perl SNMP module that vcpkg does not currently package. Avoid shipping them
    # as part of the vcpkg toolset because they are not usable as-is in a portable
    # package layout.
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/bin/mib2c"
        "${CURRENT_PACKAGES_DIR}/bin/mib2c.bat"
        "${CURRENT_PACKAGES_DIR}/bin/snmpconf"
        "${CURRENT_PACKAGES_DIR}/bin/snmpconf.bat"
        "${CURRENT_PACKAGES_DIR}/bin/traptoemail"
        "${CURRENT_PACKAGES_DIR}/bin/traptoemail.bat"
    )

    vcpkg_copy_tools(
        TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin"
        DESTINATION "${NET_SNMP_TOOL_DIR}"
        AUTO_CLEAN
    )
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
