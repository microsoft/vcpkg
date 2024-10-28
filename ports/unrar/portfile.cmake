set(UNRAR_VERSION "7.0.7")
set(UNRAR_SHA512 7151a42742d4c34a8f03c58dae471f80788b76adbb52188759b7fc7357757f88fa9d980de006ce48732c40f326b92b79fb069e807c2b66d4387ee60433a8accb)
set(UNRAR_FILENAME unrarsrc-${UNRAR_VERSION}.tar.gz)
set(UNRAR_URL https://www.rarlab.com/rar/${UNRAR_FILENAME})

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

#SRC
vcpkg_download_distfile(ARCHIVE
    URLS ${UNRAR_URL}
    FILENAME ${UNRAR_FILENAME}
    SHA512 ${UNRAR_SHA512}
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE ${UNRAR_VERSION}
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "UnRARDll.vcxproj"
)

#INCLUDE (named dll.hpp in source, and unrar.h in all rarlabs distributions)
file(INSTALL "${SOURCE_PATH}/dll.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME unrar.h)

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-unrar/unofficial-unrar-config.cmake" @ONLY)

#COPYRIGHT
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
