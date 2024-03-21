# nmap is a tools, so ignor POST_CHECK
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://nmap.org/dist/nmap-7.70.tar.bz2"
    FILENAME "nmap-7.70.tar.bz2"
    SHA512 084c148b022ff6550e269d976d0077f7932a10e2ef218236fe13aa3a70b4eb6506df03329868fc68cb3ce78e4360b200f5a7a491d3145028fed679ef1c9ecae5
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            fix-snprintf.patch
            fix-ssize_t.patch
            fix-msvc-prj.patch
    )
    list(APPEND DEL_PROJS "libpcap" "libpcre" "libssh2" "libz")
    foreach (DEL_PROJ ${DEL_PROJS})
        file(REMOVE_RECURSE "${SOURCE_PATH}/${DEL_PROJ}")
    endforeach()

  if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/bin/Packet.dll")
    vcpkg_replace_string("${SOURCE_PATH}/mswin32/pcap-include/pcap/export-defs.h" "#define PCAP_API_DEF	__declspec(dllimport)" "#define PCAP_API_DEF		")
  else() # editable
    vcpkg_replace_string("${SOURCE_PATH}/mswin32/pcap-include/pcap/export-defs.h" "#define PCAP_API_DEF		" "#define PCAP_API_DEF	__declspec(dllimport)")
  endif()

    # Clear
    vcpkg_execute_required_process(
        COMMAND "devenv.exe"
                "nmap.sln"
                /Clean
        WORKING_DIRECTORY ${SOURCE_PATH}/mswin32
    )
    # Uprade
    message(STATUS "Upgrade solution...")
    vcpkg_execute_required_process(
        COMMAND "devenv.exe"
                "nmap.sln"
                /Upgrade
        WORKING_DIRECTORY ${SOURCE_PATH}/mswin32
        LOGNAME upgrade-Packet-${TARGET_TRIPLET}
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/mswin32/Lib")
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH mswin32/nmap.vcxproj
        PLATFORM ${MSBUILD_PLATFORM}
        ADDITIONAL_LIBS Packet.lib wpcap.lib User32.lib Crypt32.lib
    )
else()
    set(ENV{LDFLAGS} "$ENV{LDFLAGS} -pthread")
    set(OPTIONS --without-nmap-update --with-openssl=${CURRENT_INSTALLED_DIR} --with-libssh2=${CURRENT_INSTALLED_DIR} --with-libz=${CURRENT_INSTALLED_DIR} --with-libpcre=${CURRENT_INSTALLED_DIR})
    message(STATUS "Building Options: ${OPTIONS}")
    
    # Since nmap makefile has strong relationshop with codes, copy codes to obj path
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    vcpkg_extract_source_archive(source_path_release
        ARCHIVE "${ARCHIVE}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    )

    vcpkg_execute_required_process(
        COMMAND "./configure" ${OPTIONS}
    WORKING_DIRECTORY "${source_path_release}"
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND make
        WORKING_DIRECTORY "${source_path_release}"
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
    
    message(STATUS "Installing ${TARGET_TRIPLET}-rel")
    file(INSTALL "${source_path_release}/nmap" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
    
    if (NOT VCPKG_BUILD_TYPE)
        # Since nmap makefile has strong relationshop with codes, copy codes to obj path
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        vcpkg_extract_source_archive(source_path_debug
            ARCHIVE "${ARCHIVE}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        )

        vcpkg_execute_required_process(
            COMMAND "./configure" ${OPTIONS}
            WORKING_DIRECTORY ${source_path_debug}
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND make
            WORKING_DIRECTORY ${source_path_debug}
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        
        message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
        file(INSTALL ${source_path_release}/nmap DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
    endif()
    
    set(SOURCE_PATH "${source_path_release}")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
