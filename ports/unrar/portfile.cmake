vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.rarlab.com/rar/unrarsrc-${VERSION}.tar.gz"
    FILENAME "unrarsrc-${VERSION}.tar.gz"
    SHA512 e0a317418fa9c853295f69f0fbb53d1caae493405b8785ab04ac612c87b9e294f4331108ca3650a75bca91acfb5f6907d00360a9579425b2f2eae12dcae40f96
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

#COPYRIGHT
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
