include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yixuan/spectra
    REF v0.7.0
    SHA512 2a1cd9eed6cebabb551cc2f662d38d75c6b24edc8f19ee4feb122958653ecb4533b936447d36712225b48a4f1aa6590b17ca5076d78d506a515e8701752bf32d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spectra RENAME copyright)
