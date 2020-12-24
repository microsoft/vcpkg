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
)

# Remove these files on the cmake next update
vcpkg_download_distfile(ARCHIVE_PKGCONFIG
    URLS "https://gitlab.kitware.com/cmake/cmake/-/raw/ab8bd48352df060c4ead210fe30dc4736646206b/Modules/FindPkgConfig.cmake?inline=false"
    FILENAME "FindPkgConfig.cmake"
    SHA512 d9aada8107eac9ada197d0b1e9040cd3707de7f5838c90bca80321e8eb35931f520635800bea0e2aafeca7fafb08b8e4752d5c6c2d6b1a5d5b4e3225d7818aa6
)
vcpkg_download_distfile(ARCHIVE_PKGHSA
    URLS "https://gitlab.kitware.com/cmake/cmake/-/raw/ab8bd48352df060c4ead210fe30dc4736646206b/Modules/FindPackageHandleStandardArgs.cmake?inline=false"
    FILENAME "FindPackageHandleStandardArgs.cmake"
    SHA512 61a459a9e0797f976fae36ce4fd5a18a30bd13e8bc9d65d165ca760e13ddc27a8c8ad371ad4b41cc36fe227425424fe9bc6e4dfa5cfdc68bd59a3c10005cf3b4
)
vcpkg_download_distfile(ARCHIVE_PKGMSG
    URLS "https://gitlab.kitware.com/cmake/cmake/-/raw/ab8bd48352df060c4ead210fe30dc4736646206b/Modules/FindPackageMessage.cmake?inline=false"
    FILENAME "FindPackageMessage.cmake"
    SHA512 44af652038ecd98c1e54f440e67994759345290530b36f687b7e6d5c310caa55597f3718901fe7a3f8816b560f03b8f238d90aab6ce9b1b24391ab0bb2aa44a8
)
file(COPY ${ARCHIVE_PKGCONFIG} ${ARCHIVE_PKGHSA} ${ARCHIVE_PKGMSG} DESTINATION ${SOURCE_PATH}/cmake/modules)

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
