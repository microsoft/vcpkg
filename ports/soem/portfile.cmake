include(vcpkg_common_functions)

set(SOEM_VERSION 1.4.0)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/OpenEtherCATsociety/SOEM/archive/v${SOEM_VERSION}.tar.gz"
    FILENAME "SOEM-${SOEM_VERSION}.tar.gz"
    SHA512 4f1118e48908552c664f45f369e6fde09aba11ce72fa6a3a15f5805a280d77d998e0c92f1647185981aebc717037f62bac8b362444317405e795988a2ddbddd3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SOEM_VERSION}
    PATCHES
        winpcap.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/soem)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/soem/LICENSE ${CURRENT_PACKAGES_DIR}/share/soem/copyright)
