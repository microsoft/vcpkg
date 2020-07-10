vcpkg_fail_port_install(ON_TARGET "Windows")

set(CHIMERA_VERSION "5.3.0")
set(PCRE_VERSION "8.41")

# checkout hyperscan source code which is required by and also contains chimera
vcpkg_from_github(
    OUT_SOURCE_PATH CHIMERA_SOURCE_PATH
    REPO intel/hyperscan
    REF c00683d73916e39f01b0d418f686c8b5c379159c
    SHA512 3c4d52706901acc9ef4c3d12b0e5b2956f4e6bce13f6828a4ba3b736c05ffacb1d733ef9c226988ca80220584525f9cb6dcfe4914ced6cc34ae6a0a45975afb5
    HEAD_REF master
)

# downlaod pcre-8.41 source code which is required by chimera
vcpkg_download_distfile(ARCHIVE_PCRE
    URLS "https://ftp.pcre.org/pub/pcre/pcre-8.41.zip"
    FILENAME "pcre-8.41.zip"
    SHA512 a3fd57090a5d9ce9d608aeecd59f42f04deea5b86a5c5899bdb25b18d8ec3a89b2b52b62e325c6485a87411eb65f1421604f80c3eaa653bd7dbab05ad22795ea
)

# extract pcre source code to hyperscan root
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PCRE_SOURCE_PATH
    ARCHIVE ${ARCHIVE_PCRE}
    WORKING_DIRECTORY ${CHIMERA_SOURCE_PATH}
)

# rename the pcre source code folder to pcre-8.41 which is required by chimera
file(REMOVE_RECURSE "${CHIMERA_SOURCE_PATH}/pcre-${PCRE_VERSION}")
file(RENAME "${PCRE_SOURCE_PATH}" "${CHIMERA_SOURCE_PATH}/pcre-${PCRE_VERSION}")

vcpkg_configure_cmake(
    SOURCE_PATH ${CHIMERA_SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# remove debug dir
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${CHIMERA_SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
