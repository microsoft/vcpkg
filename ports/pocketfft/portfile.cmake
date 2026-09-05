vcpkg_from_github(
    OUT_SOURCE_PATH src_path
    REPO mreineck/pocketfft
    REF 0fa0ef591e38c2758e3184c6c23e497b9f732ffa
    SHA512 b606512d452ba87aa0024a464c34df52be2e808f8cca5abbcd63a37830a1a4e4f45ca971f5da2ee5456694ab7c6d840c0b0af82be0db6af3df0c6aa4c00336bf
    HEAD_REF cpp
)

set(VCPKG_BUILD_TYPE release) # header only

file(COPY "${src_path}/pocketfft_hdronly.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${src_path}/LICENSE.md")
