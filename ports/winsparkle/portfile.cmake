vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vslavik/winsparkle/releases/download/v0.7.0/WinSparkle-0.7.0-src.zip"
    FILENAME "winsparkle-070.zip"
    SHA512 58991c821b31bbc2e7af342af6cfce2fc095841200a2a2359d3fd784d804e1bfddcb640ba8427614732e43bc1608f203e2f03274d8f942e66ad40d5ac2554891
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# build and install 
vcpkg_install_msbuild(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "WinSparkle-2017.sln"
    LICENSE_SUBPATH "COPYING"
    INCLUDES_SUBPATH "include"
    ALLOW_ROOT_INCLUDES
    PLATFORM ${BUILD_ARCH}
    TARGET_PLATFORM_VERSION ${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}
    PLATFORM_TOOLSET ${VCPKG_PLATFORM_TOOLSET}
    OPTIONS /t:restore /p:RestorePackagesConfig=true
    USE_VCPKG_INTEGRATION
)

# These libraries are useless, so remove.
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libcharset-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libcharset-1.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libgcc_s_dw2-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libgcc_s_dw2-1.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libgettextlib-0-20-2.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libgettextlib-0-20-2.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libgettextpo-0.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libgettextpo-0.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libgettextsrc-0-20-2.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libgettextsrc-0-20-2.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libgomp-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libgomp-1.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libiconv-2.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libiconv-2.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libintl-8.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libintl-8.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libstdc++-6.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libstdc++-6.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libtextstyle-0.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libtextstyle-0.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libwinpthread-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libwinpthread-1.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libcharset-1.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libcharset-1.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/COPYING.lib ${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.lib)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()


