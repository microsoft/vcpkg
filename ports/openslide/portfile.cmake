set(OPENSLIDE_VERSION "3.4.1")
set(OPENSLIDE_VERSION_SHA dfab4de1cc0c5599d0128e59957a43ecf6f75ea773d87e58967afe54733e4bcc0ef08573723194a33e7b1da8054a458f509f15a1b4830776d2851b83a9af279b)
set(OPENSLIDE_WINBUILD_VERSION "20171122")
set(OPENSLIDE_WINBUILD_VERSION_SHA 85cd61955b383f308441a1c383dd3c28eec8192c97b38791a7a637049bb059e79bffc90d0ec85e855a23fd894aa18c93ee6b3735a2fb54c700b6282fcd7451ab)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(WINBUILD
        URLS "https://github.com/openslide/openslide-winbuild/releases/download/v${OPENSLIDE_WINBUILD_VERSION}/openslide-winbuild-${OPENSLIDE_WINBUILD_VERSION}.zip"
        FILENAME "openslide-winbuild-${OPENSLIDE_WINBUILD_VERSION}.zip"
        SHA512 ${OPENSLIDE_WINBUILD_VERSION_SHA}
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        WINBUILD ${WINBUILD}
    )

    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/build.sh"
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/build
        LOGNAME build-${TARGET_TRIPLET}
    )
else(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/openslide/openslide/releases/download/v${OPENSLIDE_VERSION}/openslide-${OPENSLIDE_VERSION}.tar.gz"
        FILENAME "openslide-${OPENSLIDE_VERSION}.tar.gz"
        SHA512 ${OPENSLIDE_VERSION_SHA}
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
    )

    vcpkg_configure_make(SOURCE_PATH ${SOURCE_PATH})
    vcpkg_install_make()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)