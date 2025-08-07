vcpkg_from_github(
    OUT_SOURCE_PATH src_path
    REPO mreineck/pocketfft
    REF 9efd4da52cf8d28d14531d14e43ad9d913807546
    SHA512 e8c2b65b23feb53f1077b3ae1e0e20d21d8f55601bd1216443af0fbc916638c3649527494ec2f23bed42d562341e0cf1fcde54c37068333161f289d23d8a9009
    HEAD_REF cpp
)

set(VCPKG_BUILD_TYPE release) # header only

file(COPY "${src_path}/pocketfft_hdronly.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${src_path}/LICENSE.md")
