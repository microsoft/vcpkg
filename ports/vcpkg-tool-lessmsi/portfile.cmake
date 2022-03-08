set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(version v1.10.0)

vcpkg_download_distfile(archive_path
    URLS "https://github.com/activescott/lessmsi/releases/download/${version}/lessmsi-${version}.zip"
    FILENAME "lessmsi-${version}"
    SHA512 91be9363d75e8ca0129304008ddc26fe575cc4fd76d7f43ef0a6ff414855dc1c6e412f4e694b2950026e02cc3d31b18bd8c2e4c03e1ddce01477f3f2d2197479
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_execute_in_download_mode(
                    COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
                    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
                )

