include_guard(GLOBAL)
set(version v2.2.0)
find_program(LESSMSI PATHS "${DOWNLOADS}/lessmsi-${version}")
if(NOT LESSMSI)
    vcpkg_download_distfile(archive_path
        URLS "https://github.com/activescott/lessmsi/releases/download/${version}/lessmsi-${version}.zip"
        FILENAME "lessmsi-${version}.zip"
        SHA512 1b66099220175019d7fefe2c4b3f40a92b5bbf077e2100371cf3b9ca98c6ef3bdacb994159a55bcc7759b8890a8cfaeb84f7347ec4f7f23410f185ce5a4124e4
    )
    file(MAKE_DIRECTORY "${DOWNLOADS}/lessmsi-${version}")
    file(ARCHIVE_EXTRACT
        INPUT "${archive_path}"
        DESTINATION "${DOWNLOADS}/lessmsi-${version}"
    )
    set(LESSMSI "${DOWNLOADS}/lessmsi-${version}/lessmsi@VCPKG_TARGET_EXECUTABLE_SUFFIX@")
endif()
