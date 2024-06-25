# "supports": "!uwp & !(osx & arm64)",
set(VERSION 7.8.0)

if(VCPKG_TARGET_IS_OSX)
  message("${PORT} currently requires the following packages:\n    autoconf\n    libtool\nThis can be installed on MacOS systems via\n    brew install -y autoconf libtool\nNote that Homebrew installs `libtool` as `glibtool` by default.")
elseif(NOT VCPKG_TARGET_IS_WINDOWS)
  message("${PORT} currently requires the following library from the system package manager:\n    gettext\n    automake\n    libtool\nIt can be installed with apt-get install gettext automake libtool")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/heimdal/heimdal/releases/download/heimdal-${VERSION}/heimdal-${VERSION}.tar.gz"
    FILENAME "heimdal-${VERSION}.tar.gz"
    SHA512 0167345aca77d65b7a1113874eee5b65ec6e1fec1f196d57e571265409fa35ef95a673a4fd4aafbb0ab5fb5b246b97412353a68d6613a8aff6393a9f1e72999e
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ldap       HEIMDAL_LDAP
)

vcpkg_list(SET options)
vcpkg_list(APPEND options "--without-berkeley-db")
vcpkg_list(APPEND options "--disable-otp")
vcpkg_list(APPEND options "--disable-heimdal-documentation")

if(HEIMDAL_LDAP)
    vcpkg_list(APPEND options "--with-openldap")
endif()

set(OPTIONS "${options}")

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -fPIC -O0 -g -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME configure-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME install-${TARGET_TRIPLET}-dbg
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE} -fPIC -O3 -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME configure-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME install-${TARGET_TRIPLET}-rel
)

# vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
