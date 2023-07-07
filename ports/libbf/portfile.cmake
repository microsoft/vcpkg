vcpkg_download_distfile(
    STDEXCEPT_PATCH
    URLS https://github.com/mavam/libbf/commit/7720a2cdfdf211ac10d5f9c5b0988e1cae03d3ba.patch?full_index=1
    SHA512 0f414bec3797361ad8c0cd2c869d21ee9c8f05609d2c00295e0b7cf252ca42ad2230bfece7dde839ac5d47221b54034446056337f16739a346510a14b383566c
    FILENAME 7720a2cdfdf211ac10d5f9c5b0988e1cae03d3ba.patch
)

vcpkg_download_distfile(
    ALGORITHM_PATCH
    URLS https://github.com/mavam/libbf/commit/b2168dc4590a0251ec40ada4ab835eb3aec893e7.patch?full_index=1
    SHA512 549163cec577d611c382d50f2dfbd99716f54d2d95b675ebd1cde5842e795b64272116cc0997c1415dad916cb7d1f538bd275d4f57013224af1eb9af7cfdf2e6
    FILENAME b2168dc4590a0251ec40ada4ab835eb3aec893e7.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mavam/libbf
    REF v1.0.0
    SHA512 04db7adbeb4bc6b20aed7f2676840499ed1afe499b4cab67f27d4a0ad234c1fb06eced24259f37870ec4760fe74d6d6307b5d11b3cd928b975661eb2966d4db8
    HEAD_REF master
    PATCHES
        "${STDEXCEPT_PATCH}"
        "${ALGORITHM_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
