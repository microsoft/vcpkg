# nmap is a tools, so ignor POST_CHECK
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://nmap.org/dist/nmap-7.70.tar.bz2"
    FILENAME "nmap-7.70.tar.bz2"
    SHA512 084c148b022ff6550e269d976d0077f7932a10e2ef218236fe13aa3a70b4eb6506df03329868fc68cb3ce78e4360b200f5a7a491d3145028fed679ef1c9ecae5
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            fix-snprintf.patch
            fix-ssize_t.patch
            fix-msvc-prj.patch
    )
    list(APPEND DEL_PROJS "libpcap" "libpcre" "libssh2" "libz")
    foreach (DEL_PROJ ${DEL_PROJS})
        file(REMOVE_RECURSE ${SOURCE_PATH}/${DEL_PROJ})
    endforeach()
    
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
    # Build
    vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/mswin32/nmap.vcxproj
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
    )
    
    # Install
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL Release)
        file(INSTALL ${SOURCE_PATH}/mswin32/Release/nmap.exe
                     ${SOURCE_PATH}/mswin32/Release/nmap.pdb
                     DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL Debug)
        file(INSTALL ${SOURCE_PATH}/mswin32/Debug/nmap.exe
                     ${SOURCE_PATH}/mswin32/Debug/nmap.pdb
                     DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()
else()
    set(ENV{LDFLAGS} "$ENV{LDFLAGS} -pthread")
    foreach(BUILD_TYPE rel dbg)
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
        # Since nmap makefile has strong relationshop with codes, copy codes to obj path
        vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})

    endforeach()
    set(OPTIONS --without-nmap-update --with-openssl=${CURRENT_INSTALLED_DIR} --with-libssh2=${CURRENT_INSTALLED_DIR} --with-libz=${CURRENT_INSTALLED_DIR} --with-libpcre=${CURRENT_INSTALLED_DIR})
    message(STATUS "Building Options: ${OPTIONS}")
    
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL Release)
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/nmap-7.70)

        vcpkg_execute_required_process(
            COMMAND "./configure" ${OPTIONS}
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        
        message(STATUS "Building ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND make
            WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        
        message(STATUS "Installing ${TARGET_TRIPLET}-rel")
        file(INSTALL ${SOURCE_PATH_RELEASE}/nmap DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()
    
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL Debug)
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        set(SOURCE_PATH_DEBUG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/nmap-7.70)

        vcpkg_execute_required_process(
            COMMAND "./configure" ${OPTIONS}
            WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND make
            WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        
        message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
        file(INSTALL ${SOURCE_PATH_RELEASE}/nmap DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
    endif()
    
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/nmap-7.70)
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
