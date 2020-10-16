# This portfile adds the Qt Cryptographic Arcitecture
# Changes to the original build:
#   No -qt5 suffix, which is recommended just for Linux
#   Output directories according to vcpkg
#   Updated certstore. See certstore.pem in the output dirs
#
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/qca
    REF v2.3.1
    SHA512 e04a44fb395e24fd009bb6b005282880bef84ca492b5e15903f9ce3e5e3f93beae3a386a1a381507ed5b0c6550e64c6bf434328f9d965fa7f7d638c3e5d5948b
    PATCHES
        0001-fix-path-for-vcpkg.patch
        0002-fix-build-error.patch
        0003-disable-plugin-botan.patch
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
file(REMOVE ${SOURCE_PATH}/certs/rootcerts.pem)
# Using file(DOWNLOAD) to use https
file(DOWNLOAD https://raw.githubusercontent.com/mozilla/gecko-dev/master/security/nss/lib/ckfw/builtins/certdata.txt
    ${CURRENT_BUILDTREES_DIR}/cert/certdata.txt
    TLS_VERIFY ON
)
vcpkg_execute_required_process(
    COMMAND ${PERL} ${CMAKE_CURRENT_LIST_DIR}/mk-ca-bundle.pl -n ${SOURCE_PATH}/certs/rootcerts.pem
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/cert
    LOGNAME ca-bundle
)
message(STATUS "Importing certstore done")

# Configure and build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_RELATIVE_PATHS=ON
        -DQT4_BUILD=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DQCA_SUFFIX=OFF
        -DQCA_FEATURE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/qca/mkspecs/features
        -DOSX_FRAMEWORK=OFF
    OPTIONS_DEBUG
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_FEATURE_INSTALL_DIR_DEBUG}
    OPTIONS_RELEASE
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_FEATURE_INSTALL_DIR_RELEASE}
)

vcpkg_install_cmake()

# Patch and copy cmake files
message(STATUS "Patching files")
file(READ 
    ${CURRENT_PACKAGES_DIR}/debug/share/qca/cmake/QcaTargets-debug.cmake
    QCA_DEBUG_CONFIG
)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" QCA_DEBUG_CONFIG "${QCA_DEBUG_CONFIG}")
file(WRITE 
    ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets-debug.cmake
    "${QCA_DEBUG_CONFIG}"
)

file(READ ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets.cmake
    QCA_TARGET_CONFIG
)
string(REPLACE "packages/qca_" "installed/" QCA_TARGET_CONFIG "${QCA_TARGET_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/qca/cmake/QcaTargets.cmake
    "${QCA_TARGET_CONFIG}"
)

# Remove unneeded dirs
file(REMOVE_RECURSE 
    ${CURRENT_BUILDTREES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)
message(STATUS "Patching files done")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
