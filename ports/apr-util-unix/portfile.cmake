include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://archive.apache.org/dist/apr/apr-util-1.6.1.tar.bz2"
    FILENAME "apr-util-1.6.1.tar.bz2"
    SHA512 40eff8a37c0634f7fdddd6ca5e596b38de15fd10767a34c30bbe49c632816e8f3e1e230678034f578dd5816a94f246fb5dfdf48d644829af13bf28de3225205d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
)

message(STATUS "Configuring apr-util")
vcpkg_execute_required_process(
    COMMAND "./configure" --prefix=${CURRENT_INSTALLED_DIR} --with-apr=${CURRENT_INSTALLED_DIR} --with-openssl=${CURRENT_INSTALLED_DIR} --with-expat=${CURRENT_INSTALLED_DIR}
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

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr-util-unix RENAME copyright)
