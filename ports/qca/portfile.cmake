# This portfile adds the Qt Cryptographic Arcitecture
# Changes to the original build:
#   No -qt5 suffix, which is recommended just for Linux
#   Output directories according to vcpkg
#   Updated certstore. See certstore.pem in the output dirs
#
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/qca
    REF v2.3.4
    SHA512 04583da17531538fc2a7ae18a1a4f89f1e8d303e2bb390520a8f55a20bab17f8407ab07aefef2a75587e2a0521f41b37a9fdd8430ec483daf5d02c05556b8ddb
    PATCHES
        0001-fix-path-for-vcpkg.patch
        0002-fix-build-error.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(QCA_FEATURE_INSTALL_DIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/Qca)
  set(QCA_FEATURE_INSTALL_DIR_RELEASE ${CURRENT_PACKAGES_DIR}/bin/Qca)
else()
  set(QCA_FEATURE_INSTALL_DIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/Qca)
  set(QCA_FEATURE_INSTALL_DIR_RELEASE ${CURRENT_PACKAGES_DIR}/lib/Qca)
endif()

# According to:
#   https://www.openssl.org/docs/faq.html#USER16
# it is up to developers or admins to maintain CAs.
# So we do it here:
message(STATUS "Importing certstore")
file(REMOVE "${SOURCE_PATH}/certs/rootcerts.pem")
# Using file(DOWNLOAD) to use https
file(DOWNLOAD https://raw.githubusercontent.com/mozilla/gecko-dev/master/security/nss/lib/ckfw/builtins/certdata.txt
    "${CURRENT_BUILDTREES_DIR}/cert/certdata.txt"
    TLS_VERIFY ON
)
vcpkg_execute_required_process(
    COMMAND "${PERL}" "${CMAKE_CURRENT_LIST_DIR}/mk-ca-bundle.pl" -n "${SOURCE_PATH}/certs/rootcerts.pem"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cert"
    LOGNAME ca-bundle
)
message(STATUS "Importing certstore done")

if("botan" IN_LIST FEATURES)
    list(APPEND QCA_OPTIONS -DWITH_botan_PLUGIN="yes")
else()
    list(APPEND QCA_OPTIONS -DWITH_botan_PLUGIN="no")
endif()

# Configure and build
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_RELATIVE_PATHS=ON
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DQCA_SUFFIX=OFF
        -DQCA_FEATURE_INSTALL_DIR=share/qca/mkspecs/features
        -DOSX_FRAMEWORK=OFF
        ${QCA_OPTIONS}
    OPTIONS_DEBUG
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_FEATURE_INSTALL_DIR_DEBUG}
    OPTIONS_RELEASE
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_FEATURE_INSTALL_DIR_RELEASE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/qca/cmake)
file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/QcaConfig.cmake" QCA_CONFIG_FILE)
string(REGEX REPLACE "PACKAGE_PREFIX_DIR \"(.*)\" ABSOLUTE"
                     [[PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE]]
       QCA_CONFIG_FILE "${QCA_CONFIG_FILE}"
)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/QcaConfig.cmake" "${QCA_CONFIG_FILE}")

# Remove unneeded dirs
file(REMOVE_RECURSE 
    "${CURRENT_BUILDTREES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
