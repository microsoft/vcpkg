# This portfile adds the Qt Cryptographic Arcitecture
# Changes to the original build:
#   No -qt5 suffix, which is recommended just for Linux
#   Output directories according to vcpkg
#   Updated certstore. See certstore.pem in the output dirs
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)

find_program(GIT git)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

# Set git variables to qca version 2.2.0 commit 
set(GIT_URL "git://anongit.kde.org/qca.git")
set(GIT_REF "19ec49f89a0a560590ec733c549b92e199792837") # Commit

# Prepare source dir
if(NOT EXISTS "${DOWNLOADS}/qca.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/qca.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/qca.git
        LOGNAME worktree
    )
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# Apply the patch to install to the expected folders
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-fix-path-for-vcpkg.patch
)

# According to:
#   https://www.openssl.org/docs/faq.html#USER16
# it is up to developers or admins to maintain CAs.
# So we do it here:
message(STATUS "Importing certstore")
file(REMOVE ${SOURCE_PATH}/certs/rootcerts.pem)
# Using file(DOWNLOAD) to use https
file(DOWNLOAD https://raw.githubusercontent.com/mozilla/gecko-dev/master/security/nss/lib/ckfw/builtins/certdata.txt
    ${CMAKE_CURRENT_LIST_DIR}/certdata.txt
    TLS_VERIFY ON
)
vcpkg_execute_required_process(
    COMMAND ${PERL} ${CMAKE_CURRENT_LIST_DIR}/mk-ca-bundle.pl -n ${SOURCE_PATH}/certs/rootcerts.pem
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    LOGNAME ca-bundle
)
message(STATUS "Importing certstore done")

# Configure and build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    CURRENT_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
        -DUSE_RELATIVE_PATHS=ON
        -DQT4_BUILD=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DQCA_SUFFIX=OFF
        -DQCA_FEATURE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/qca/mkspecs/features
    OPTIONS_DEBUG
        -DQCA_PLUGINS_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/bin/Qca
    OPTIONS_RELEASE
        -DQCA_PLUGINS_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/bin/Qca
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
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qca)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qca/COPYING ${CURRENT_PACKAGES_DIR}/share/qca/copyright)
