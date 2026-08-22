include_guard(GLOBAL)
set(version v1.10.0)
find_program(LESSMSI PATHS "${DOWNLOADS}/lessmsi-${version}")
if(NOT LESSMSI)
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/activescott/lessmsi/releases/download/${version}/lessmsi-${version}.zip"
        FILENAME "lessmsi-${version}.zip"
        SHA512 91be9363d75e8ca0129304008ddc26fe575cc4fd76d7f43ef0a6ff414855dc1c6e412f4e694b2950026e02cc3d31b18bd8c2e4c03e1ddce01477f3f2d2197479
    )
    file(MAKE_DIRECTORY "${DOWNLOADS}/lessmsi-${version}")
    file(ARCHIVE_EXTRACT
        INPUT "${archive_path}"
        DESTINATION "${DOWNLOADS}/lessmsi-${version}"
    )
    set(LESSMSI "${DOWNLOADS}/lessmsi-${version}/lessmsi@VCPKG_TARGET_EXECUTABLE_SUFFIX@")
endif()
