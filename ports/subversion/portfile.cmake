if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION 1.14.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/subversion/subversion-${VERSION}.tar.bz2"
    FILENAME "subversion-${VERSION}.tar.bz2"
    SHA512 0a70c7152b77cdbcb810a029263e4b3240b6ef41d1c19714e793594088d3cca758d40dfbc05622a806b06463becb73207df249393924ce591026b749b875fcdd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-libserf.patch
        fix-libexpat-static.patch
)

vcpkg_find_acquire_program(PYTHON3)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  set(MSBUILD_PLATFORM x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  set(MSBUILD_PLATFORM Win32)
else()
  message(FATAL_ERROR "${PORT} does not currently support this platform")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BUILD_MODE --with-shared-serf)
else()
  set(BUILD_MODE --with-static-apr --with-static-openssl --disable-shared)
endif()

# ### TODO: Maybe add
# --with-httpd=${CURRENT_INSTALLED_DIR} # For mod_dav_svn (requires Apache HTTPD)
# --with-sasl=${CURRENT_INSTALLED_DIR} # For sasls in svn:// (requires Cyrus Sasl)

vcpkg_execute_build_process(
    COMMAND ${PYTHON3} gen-make.py
        -t vcproj --vsnet-version=2019 # Actual version is overridden during MSBuild step.
        --with-apr=${CURRENT_INSTALLED_DIR}
        --with-apr-util=${CURRENT_INSTALLED_DIR}
        --with-openssl=${CURRENT_INSTALLED_DIR}
        --with-serf=${CURRENT_INSTALLED_DIR}
        --with-sqlite=${CURRENT_INSTALLED_DIR}
        --with-zlib=${CURRENT_INSTALLED_DIR}
        ${BUILD_MODE}
        -D SVN_HI_RES_SLEEP_MS=1
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/subversion_vcnet.sln
    TARGET __ALL__
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
)

if (VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(GLOB_RECURSE SVN_BIN_rel
            ${SOURCE_PATH}/Release/subversion/libsvn*.dll
            ${SOURCE_PATH}/Release/tools/libsvn*.dll)

        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
     endif()

    file(GLOB_RECURSE SVN_EXE_rel
        ${SOURCE_PATH}/Release/subversion/svn*.exe
        ${SOURCE_PATH}/Release/tools/svn*.pdb)

    file(GLOB_RECURSE SVN_LIBS_rel
        ${SOURCE_PATH}/Release/subversion/libsvn*.lib)

    file(GLOB_RECURSE SVN_PDB_rel
        ${SOURCE_PATH}/Release/subversion/libsvn*.pdb
        ${SOURCE_PATH}/Release/tools/libsvn*.pdb)

    file(GLOB_RECURSE SVN_BIN_dbg
        ${SOURCE_PATH}/Debug/subversion/libsvn*.dll
        ${SOURCE_PATH}/Debug/tools/libsvn*.dll)

    file(GLOB_RECURSE SVN_EXE_dbg
        ${SOURCE_PATH}/Debug/subversion/svn*.exe
        ${SOURCE_PATH}/Debug/tools/svn*.pdb)

    file(GLOB_RECURSE SVN_LIBS_dbg
        ${SOURCE_PATH}/Debug/subversion/libsvn*.lib)

    file(GLOB_RECURSE SVN_PDB_dbg
        ${SOURCE_PATH}/Debug/subversion/libsvn*.pdb
        ${SOURCE_PATH}/Debug/tools/libsvn*.pdb)

    file(GLOB SVN_INCLUDES
      ${SOURCE_PATH}/subversion/include/*.h)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/subversion/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/subversion/debug/bin)

    file(COPY ${SVN_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    file(COPY ${SVN_LIBS_rel} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SVN_LIBS_dbg} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    file(COPY ${SVN_EXE_rel} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/subversion/bin)
    file(COPY ${SVN_EXE_dbg} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/subversion/debug/bin)

    file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/subversion/copyright)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${SVN_BIN_rel} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SVN_BIN_dbg} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

        file(COPY ${SVN_PDB_rel} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SVN_PDB_dbg} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    else()
        file(COPY ${SVN_PDB_rel} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY ${SVN_PDB_dbg} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()

endif()