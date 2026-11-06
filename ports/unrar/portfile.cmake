vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.rarlab.com/rar/unrarsrc-${VERSION}.tar.gz"
    FILENAME "unrarsrc-${VERSION}.tar.gz"
    SHA512 3ad68c69f7ab1e566e2146196055c85546bbf1d3ac56c51b24bb990a656f28540d52bd62b1a00d6bad2631d06d62208a447450107f9c404afbff68c244fd4427
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE ${VERSION}
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "UnRARDll.vcxproj"
)

#INCLUDE (named dll.hpp in source, and unrar.h in all rarlabs distributions)
file(INSTALL "${SOURCE_PATH}/dll.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME unrar.h)

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-unrar/unofficial-unrar-config.cmake" @ONLY)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/acknow.txt"
)
