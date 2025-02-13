# EGL_PATCH is temporarily required for the Windows builds
# It can be safely deleted in the next release
vcpkg_download_distfile(EGL_PATCH
    URLS https://github.com/ABRG-Models/morphologica/commit/9224a389bb1a5d0d7784d741e512afed8b7cc8e4.patch?full_index=1
    FILENAME fix-egl-9224a389bb1a5d0d7784d741e512afed8b7cc8e4.patch
    SHA512 ad20f46d6473880abb5e6ac795cf68bb25150f681071eff7ac054b8b136bf4901ad06ca35cc33345c5e2ebc8a4d0d107a1758caf293596c0383f0abc94dd924d
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ABRG-Models/morphologica
    REF "v${VERSION}"
    SHA512 a81620b571b207eba50835da1722fd6320bcddc9d9b4268c43b42e71d4ee10e84210902336a515437a2406b9f56bb2f82db5f540d9d8f54d2006c6dcc671bb72 
    PATCHES
        "${EGL_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
