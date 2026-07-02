vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO net-snmp/net-snmp
    REF "v${VERSION}"
    SHA512 0a62a1d263437409cf50e20da7f82132cc3df9a7ecf9e1d57ac00285199617b168636e4a042cd564fcb1b8417883e618238ca252066b9e6e77c4c9030026ff30
    PATCHES
        msvc-openssl-autolink.patch
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_PATH}")

set(NET_SNMP_FEATURE_LIST "")
list(APPEND NET_SNMP_FEATURE_LIST "--with-sdk")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=static")
else()
    list(APPEND NET_SNMP_FEATURE_LIST "--linktype=dynamic")
endif()

set(TARGET_DIR "${CURRENT_PACKAGES_DIR}")
set(TARGET_DIR_DEBUG "${CURRENT_PACKAGES_DIR}/debug")

set(NET_SNMP_SSL "")
set(NET_SNMP_SSL_DEBUG "")

if("ssl" IN_LIST FEATURES)
    list(APPEND NET_SNMP_SSL
        "--with-ssl"
        "--with-sslincdir=${CURRENT_INSTALLED_DIR}/include"
        "--with-ssllibdir=${CURRENT_INSTALLED_DIR}/lib")
    list(APPEND NET_SNMP_SSL_DEBUG
        "--with-ssl"
        "--with-sslincdir=${CURRENT_INSTALLED_DIR}/include"
        "--with-ssllibdir=${CURRENT_INSTALLED_DIR}/debug/lib")
endif()

if("tools" IN_LIST FEATURES)
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
        "--prefix=${TARGET_DIR}"
    PRERUN_SHELL_DEBUG "${PERL}" Configure
        ${NET_SNMP_FEATURE_LIST}
        ${NET_SNMP_SSL_DEBUG}
        --config=debug
        "--prefix=${TARGET_DIR_DEBUG}"
    PROJECT_NAME "Makefile"
    TARGET ${TARGETS} install install_devel
    LOGFILE_ROOT build-net-snmp
)

file(REMOVE_RECURSE
    "${TARGET_DIR}/etc"
    "${TARGET_DIR}/temp"
    "${TARGET_DIR}/snmp"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(TARGETS STREQUAL "libs" AND EXISTS "${TARGET_DIR}/bin")
        file(REMOVE_RECURSE "${TARGET_DIR}/bin")
        file(REMOVE_RECURSE "${TARGET_DIR_DEBUG}/bin")
    endif()
endif()

file(GLOB LIB_FILES
    LIST_DIRECTORIES false
    "${TARGET_DIR}/lib/release/*")

if(LIB_FILES)
    file(MAKE_DIRECTORY "${TARGET_DIR}/lib")
    file(COPY ${LIB_FILES} DESTINATION "${TARGET_DIR}/lib")
    file(REMOVE_RECURSE "${TARGET_DIR}/lib/release")
endif()

file(GLOB LIB_FILES_DEBUG
     LIST_DIRECTORIES false
     "${TARGET_DIR_DEBUG}/lib/debug/*")

if(LIB_FILES_DEBUG)
    file(MAKE_DIRECTORY "${TARGET_DIR_DEBUG}/lib")
    file(COPY ${LIB_FILES_DEBUG} DESTINATION "${TARGET_DIR_DEBUG}/lib")
    file(REMOVE_RECURSE "${TARGET_DIR_DEBUG}/lib/debug")
endif()

# INSTALL_BASE is the compile-time default root for runtime search paths
# (MIBDIRS, SNMPCONFPATH, persistent storage, ...). Configure bakes the
# absolute buildtree path into it, which is not relocatable and trips the
# post-build absolute-path check. Restore upstream's default ("c:/usr",
# see win32/net-snmp/net-snmp-config.h.in); users are expected to override
# these paths at runtime via the environment or the registry.
vcpkg_replace_string(
    "${TARGET_DIR}/include/net-snmp/net-snmp-config.h"
    "#define INSTALL_BASE \"${TARGET_DIR}\""
    "#define INSTALL_BASE \"c:/usr\""
    IGNORE_UNCHANGED
)

file(REMOVE
    "${TARGET_DIR}/lib/netsnmp.exp"
)

if(VCPKG_BUILD_TYPE STREQUAL "release")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE
        "${TARGET_DIR_DEBUG}/bin/mib2c"
        "${TARGET_DIR_DEBUG}/bin/mib2c.bat"
        "${TARGET_DIR_DEBUG}/bin/snmpconf"
        "${TARGET_DIR_DEBUG}/bin/snmpconf.bat"
        "${TARGET_DIR_DEBUG}/bin/traptoemail"
        "${TARGET_DIR_DEBUG}/bin/traptoemail.bat"
    )
    file(REMOVE_RECURSE
        "${TARGET_DIR_DEBUG}/include"
        "${TARGET_DIR_DEBUG}/share"
        "${TARGET_DIR_DEBUG}/temp"
        "${TARGET_DIR_DEBUG}/snmp"
        "${TARGET_DIR_DEBUG}/etc"
    )
endif()

if(EXISTS "${TARGET_DIR}/bin/mib2c.bat" OR EXISTS "${TARGET_DIR}/bin/encode_keychange")
    set(NET_SNMP_TOOL_DIR "${CURRENT_PACKAGES_DIR}/tools/net-snmp")
    file(MAKE_DIRECTORY "${NET_SNMP_TOOL_DIR}")

    foreach(_tool IN ITEMS mib2c mib2c.bat snmpconf snmpconf.bat traptoemail traptoemail.bat)
        if(EXISTS "${TARGET_DIR}/bin/${_tool}")
            file(RENAME "${TARGET_DIR}/bin/${_tool}" "${NET_SNMP_TOOL_DIR}/${_tool}")
        endif()
    endforeach()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/mib2c")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/mib2c"
            "${TARGET_DIR}/share/snmp/"
            "../../share/snmp/"
            IGNORE_UNCHANGED
        )
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/mib2c"
            "${TARGET_DIR}/share/snmp/mib2c-data"
            "../../share/snmp/mib2c-data"
            IGNORE_UNCHANGED
        )
    endif()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/mib2c.bat")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/mib2c.bat"
            "set MYPERLPROGRAM=c:\\usr\\bin\\mib2c"
            "set MYPERLPROGRAM=mib2c"
            IGNORE_UNCHANGED
        )
    endif()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/snmpconf")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/snmpconf"
            "${TARGET_DIR}/share/snmp/snmpconf-data"
            "../../share/snmp/snmpconf-data"
            IGNORE_UNCHANGED
        )
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/snmpconf"
            "${TARGET_DIR}/share/snmp"
            "../../share/snmp"
            IGNORE_UNCHANGED
        )
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/snmpconf"
            "${TARGET_DIR}/etc/snmp"
            "../../share/snmp"
            IGNORE_UNCHANGED
        )
    endif()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/snmpconf.bat")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/snmpconf.bat"
            "set MYPERLPROGRAM=c:\\usr\\bin\\snmpconf"
            "set MYPERLPROGRAM=snmpconf"
            IGNORE_UNCHANGED
        )
    endif()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/traptoemail")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/traptoemail"
            "${TARGET_DIR}/bin/traptoemail"
            "traptoemail"
            IGNORE_UNCHANGED
        )
    endif()

    if(EXISTS "${NET_SNMP_TOOL_DIR}/traptoemail.bat")
        vcpkg_replace_string(
            "${NET_SNMP_TOOL_DIR}/traptoemail.bat"
            "set MYPERLPROGRAM=c:\\usr\\bin\\traptoemail"
            "set MYPERLPROGRAM=traptoemail"
            IGNORE_UNCHANGED
        )
    endif()

    if("tools" IN_LIST FEATURES)
        vcpkg_copy_tools(
            TOOL_NAMES encode_keychange snmpbulkget snmpbulkwalk snmpd snmpdelta snmpdf snmpget snmpgetnext snmpnetstat snmpset snmpstatus snmptable snmptest snmptranslate snmptrap snmptrapd snmpusm snmpvacm snmpwalk
            SEARCH_DIR "${TARGET_DIR}/bin"
            DESTINATION "${NET_SNMP_TOOL_DIR}"
            AUTO_CLEAN
        )
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
