
set(VERSION 1.1.4)

vcpkg_download_distfile(ARCHIVE
    URLS "http://w3.impa.br/~diego/software/rply/rply-${VERSION}.tar.gz"
    FILENAME "rply-${VERSION}.tar.gz"
    SHA512 be389780b8ca74658433f271682d91e89709ced588c4012c152ccf4014557692a1afd37b1bd5e567cedf9c412d42721eb0412ff3331f38717e527bd5d29c27a7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        fix-uninitialized-local-variable.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/rply.def DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/rply-config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/rply RENAME copyright)

