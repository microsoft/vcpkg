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
    REF "v${VERSION}"
    SHA512 21bbc483f78d8c6b99bf2a4375db6a1bcc8a1a16df01e2295dc6a5b43fa27ccbef39114ee33d456071f712a00aca0ab3bc1bf767df82333c2f98ea35f7d35b45
    PATCHES
        0001-fix-path-for-vcpkg.patch
        0002-fix-build-error.patch
        0003-Define-NOMINMAX-for-botan-plugin-with-MSVC.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(QCA_PLUGIN_INSTALL_DIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/Qca)
  set(QCA_PLUGIN_INSTALL_DIR_RELEASE ${CURRENT_PACKAGES_DIR}/bin/Qca)
else()
  set(QCA_PLUGIN_INSTALL_DIR_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/Qca)
  set(QCA_PLUGIN_INSTALL_DIR_RELEASE ${CURRENT_PACKAGES_DIR}/lib/Qca)
endif()

# According to:
#   https://www.openssl.org/docs/faq.html#USER16
# it is up to developers or admins to maintain CAs.
# So we do it here:
message(STATUS "Importing certstore")
file(REMOVE "${SOURCE_PATH}/certs/rootcerts.pem")

vcpkg_download_distfile(CERTDATA_TXT
    URLS     https://raw.githubusercontent.com/mozilla/gecko-dev/bc977a80f4fcf465681209d431c9dfe549f224cf/security/nss/lib/ckfw/builtins/certdata.txt
    SHA512   a43dd8fa252afc5478c0a9297899eded17a18c21f359954d81bccad8b8f5a50d4f8aedfc1b9a43f2ce01a7f5352788b864045ed006fae65ccd21ce75430bc55d
    FILENAME "certdata.txt"
)
file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cert")
file(COPY_FILE "${CERTDATA_TXT}" "${CURRENT_BUILDTREES_DIR}/cert/certdata.txt")

vcpkg_execute_required_process(
    COMMAND "${PERL}" "${CMAKE_CURRENT_LIST_DIR}/mk-ca-bundle.pl" -n "${SOURCE_PATH}/certs/rootcerts.pem"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cert"
    LOGNAME ca-bundle
)
message(STATUS "Importing certstore done")

set(PLUGINS gnupg logger wincrypto)
if("botan" IN_LIST FEATURES)
    list(APPEND PLUGINS botan)
endif()
if ("ossl" IN_LIST FEATURES)
    list(APPEND PLUGINS ossl)
endif()
if (VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Building with an osx-dynamic triplet: 'softstore' disabled.")
else()
    list(APPEND PLUGINS softstore)
endif()

# Configure and build
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_RELATIVE_PATHS=ON
        "-DBUILD_PLUGINS=${PLUGINS}"
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_WITH_QT6=ON
        -DQCA_SUFFIX=OFF
        -DQCA_FEATURE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/qca/mkspecs/features
        -DOSX_FRAMEWORK=OFF
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    OPTIONS_DEBUG
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_PLUGIN_INSTALL_DIR_DEBUG}
    OPTIONS_RELEASE
        -DQCA_PLUGINS_INSTALL_DIR=${QCA_PLUGIN_INSTALL_DIR_RELEASE}
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

vcpkg_install_copyright(
    COMMENT [[
The generated CA certificate bundle is derived from Mozilla's certdata.txt,
which is licensed under MPL-2.0:
https://raw.githubusercontent.com/mozilla/gecko-dev/bc977a80f4fcf465681209d431c9dfe549f224cf/security/nss/lib/ckfw/builtins/certdata.txt
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/src/botantools/botan/license.txt"
)
