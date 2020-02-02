
vcpkg_download_distfile(ARCHIVE
    URLS "http://archive.apache.org/dist/apr/apr-util-1.6.1.tar.bz2"
    FILENAME "apr-util-1.6.1.tar.bz2"
    SHA512 40eff8a37c0634f7fdddd6ca5e596b38de15fd10767a34c30bbe49c632816e8f3e1e230678034f578dd5816a94f246fb5dfdf48d644829af13bf28de3225205d

)

if(VCPKG_TARGET_IS_WINDOWS)

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            use-vcpkg-expat.patch
            apr.patch
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
      set(APU_DECLARE_EXPORT ON)
      set(APU_DECLARE_STATIC OFF)
    else()
      set(APU_DECLARE_EXPORT OFF)
      set(APU_DECLARE_STATIC ON)
    endif()

    vcpkg_configure_cmake(
      SOURCE_PATH ${SOURCE_PATH}
      PREFER_NINJA
      OPTIONS
        -DAPU_DECLARE_EXPORT=${APU_DECLARE_EXPORT}
        -DAPU_DECLARE_STATIC=${APU_DECLARE_STATIC}
      OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_copy_pdbs()

    file(READ ${CURRENT_PACKAGES_DIR}/include/apu.h  APU_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
      string(REPLACE "defined(APU_DECLARE_EXPORT)" "1" APU_H "${APU_H}")
    else()
      string(REPLACE "defined(APU_DECLARE_STATIC)" "1" APU_H "${APU_H}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/apu.h "${APU_H}")

else(VCPKG_TARGET_IS_WINDOWS)

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE} 
    )

    # To cross-compile you will need a triplet file that locates the tool chain and sets --host and --cache parameters of "./configure".
    # The ${VCPKG_PLATFORM_TOOLSET}.cache file must have been generated on the targeted host using "./configure -C".
    # For example, to target aarch64-linux-gnu, triplets/aarch64-linux-gnu.cmake should contain (beyond the standard content):
    # set(VCPKG_PLATFORM_TOOLSET aarch64-linux-gnu)
    # set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${MY_CROSS_DIR}/cmake/Toolchain-${VCPKG_PLATFORM_TOOLSET}.cmake)
    # set(CONFIGURE_PARAMETER_1 --host=${VCPKG_PLATFORM_TOOLSET})
    # set(CONFIGURE_PARAMETER_2 --cache-file=${MY_CROSS_DIR}/autoconf/${VCPKG_PLATFORM_TOOLSET}.cache)
    if(CONFIGURE_PARAMETER_1)
        message(STATUS "Configuring apr-util with ${CONFIGURE_PARAMETER_1} ${CONFIGURE_PARAMETER_2} ${CONFIGURE_PARAMETER_3}")
    else()
        message(STATUS "Configuring apr-util")
    endif()

    vcpkg_execute_required_process(
        COMMAND "./configure" --prefix=${CURRENT_INSTALLED_DIR} ${CONFIGURE_PARAMETER_1} ${CONFIGURE_PARAMETER_2} ${CONFIGURE_PARAMETER_3} --with-apr=${CURRENT_INSTALLED_DIR} --with-openssl=${CURRENT_INSTALLED_DIR} --with-expat=${CURRENT_INSTALLED_DIR}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "autotools-config-${TARGET_TRIPLET}"
    )

    message(STATUS "Building ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND make
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-release
    )

    message(STATUS "Installing ${TARGET_TRIPLET}")
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Installs include files to apr-util-1 sub-directory
    vcpkg_execute_required_process(
        COMMAND make install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-${TARGET_TRIPLET}-release
    )

endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
