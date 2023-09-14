function(install_autopoint)
    # variables for configuring autopoint.in
    set(PACKAGE "gettext-tools")
    set(ARCHIVE_VERSION "${VERSION}")
    set(ARCHIVE_FORMAT "dirgz")
    set(bindir [[${prefix}/tools/gettext/bin]])
    set(datadir [[${datarootdir}]])
    set(exec_prefix [[${prefix}]])
    set(PATH_SEPARATOR ":")
    set(RELOCATABLE "yes")

    file(STRINGS "${SOURCE_PATH}/gettext-tools/configure"
        VERSIONS_FROM_CONFIGURE
        REGEX "^ *(ARCHIVE_VERSION|VERSION)=.*$"
    )
    foreach(LINE IN LISTS VERSIONS_FROM_CONFIGURE)
        if(LINE MATCHES "^ *(ARCHIVE_VERSION|VERSION)='?([0-9.]+)'?$")
            set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}")
        endif()
    endforeach()

    set(WORKING_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    file(MAKE_DIRECTORY "${WORKING_DIR}")

    # autopoint script
    configure_file("${SOURCE_PATH}/gettext-tools/misc/autopoint.in" "${WORKING_DIR}/autopoint" @ONLY)

    # data tarball
    if(WIN32)
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES gzip)
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    endif()
    file(COPY "${SOURCE_PATH}/gettext-tools/misc/archive.dir.tar" DESTINATION "${WORKING_DIR}")
    vcpkg_execute_required_process(
        COMMAND gzip -f archive.dir.tar
        WORKING_DIRECTORY "${WORKING_DIR}"
        LOGNAME gzip-${TARGET_TRIPLET}
    )

    # installation
    file(INSTALL "${WORKING_DIR}/autopoint" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
      FILE_PERMISSIONS
        OWNER_WRITE OWNER_READ OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
    )
    file(INSTALL "${WORKING_DIR}/archive.dir.tar.gz" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gettext/gettext")
endfunction()
