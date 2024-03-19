vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/x86-simd-sort
    REF "v${VERSION}"
    SHA512 2e95f026515f5616a43dfdb8d2b6a0e6da3027b74bb8e21db5f7db6710cb7bf290ab147a117093fd7bfba66de6c4c0fcfde16fbe8278bd4966031662bff34ba8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
