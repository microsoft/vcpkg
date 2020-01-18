if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

set(VERSION 1.6.5)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/apr/apr-${VERSION}.tar.bz2"
    FILENAME "apr-${VERSION}.tar.bz2"
    SHA512 d3511e320457b5531f565813e626e7941f6b82864852db6aa03dd298a65dbccdcdc4bd580f5314f8be45d268388edab25efe88cf8340b7d2897a4dbe9d0a41fc
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        private-headers   INSTALL_PRIVATE_H
    )

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DINSTALL_PDB=OFF
            -DMIN_WINDOWS_VER=Windows7
            -DAPR_HAVE_IPV6=ON
            -DAPR_INSTALL_PRIVATE_H=${INSTALL_PRIVATE_H}
            ${FEATURE_OPTIONS}
        # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
        # OPTIONS_RELEASE -DOPTIMIZE=1
        # OPTIONS_DEBUG -DDEBUGGABLE=1
    )

    vcpkg_install_cmake()

    # There is no way to suppress installation of the headers in debug builds.
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

    # Both dynamic and static are built, so keep only the one needed
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/apr-1.lib
                    ${CURRENT_PACKAGES_DIR}/lib/aprapp-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/apr-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/aprapp-1.lib)
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libapr-1.lib
                    ${CURRENT_PACKAGES_DIR}/lib/libaprapp-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libapr-1.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libaprapp-1.lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

    vcpkg_copy_pdbs()
else()
    # To cross-compile you will need a triplet file that locates the tool chain and sets --host and --cache parameters of "./configure".
    # The ${VCPKG_PLATFORM_TOOLSET}.cache file must have been generated on the targeted host using "./configure -C".
    # For example, to target aarch64-linux-gnu, triplets/aarch64-linux-gnu.cmake should contain (beyond the standard content):
    # set(VCPKG_PLATFORM_TOOLSET aarch64-linux-gnu)
    # set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${MY_CROSS_DIR}/cmake/Toolchain-${VCPKG_PLATFORM_TOOLSET}.cmake)
    # set(CONFIGURE_PARAMETER_1 --host=${VCPKG_PLATFORM_TOOLSET})
    # set(CONFIGURE_PARAMETER_2 --cache-file=${MY_CROSS_DIR}/autoconf/${VCPKG_PLATFORM_TOOLSET}.cache)
    if(CONFIGURE_PARAMETER_1)
        message(STATUS "Configuring apr with ${CONFIGURE_PARAMETER_1} ${CONFIGURE_PARAMETER_2} ${CONFIGURE_PARAMETER_3}")
    else()
        message(STATUS "Configuring apr")
    endif()
    vcpkg_execute_required_process(
        COMMAND "./configure" --prefix=${CURRENT_INSTALLED_DIR} ${CONFIGURE_PARAMETER_1} ${CONFIGURE_PARAMETER_2} ${CONFIGURE_PARAMETER_3}
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
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Installs include files to apr-1 sub-directory
    vcpkg_execute_required_process(
        COMMAND make install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-${TARGET_TRIPLET}-release
    )
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/apr/LICENSE ${CURRENT_PACKAGES_DIR}/share/apr/copyright)
