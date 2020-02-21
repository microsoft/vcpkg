
set(CHIMERA_VERSION "5.2.1")
set(PCRE_VERSION "8.41")

# download hyperscan source code which is required by and also contains chimera
vcpkg_download_distfile(ARCHIVE_HYPERSCAN
    URLS "https://github.com/intel/hyperscan/archive/d79973efb1fcf5ed338122882c1f896829767fb6.zip"
    FILENAME "d79973efb1fcf5ed338122882c1f896829767fb6.zip"
    SHA512 8bf6e8c323ab3c4b3f26d871a9f89e666edba598925c99ad2f14b3e849792c51cb87bc30ad54008ec813603a9a7c94d689ad4344e1a45c10b2a891e434a678f3
)
# extract hyperscan source code which contains chimera code in a sub folder
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH CHIMERA_SOURCE_PATH
    ARCHIVE ${ARCHIVE_HYPERSCAN}
    REF ${CHIMERA_VERSION}
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
