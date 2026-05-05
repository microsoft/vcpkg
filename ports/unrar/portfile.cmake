vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.rarlab.com/rar/unrarsrc-${VERSION}.tar.gz"
    FILENAME "unrarsrc-${VERSION}.tar.gz"
    SHA512 8e2b7e801e1e1f8861657e7e613b4540c46938af377e43383ec2b509db1a59073d1e970fa20ee923db73a6c93777d677e7488ca6696177625cc1020922504346
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
