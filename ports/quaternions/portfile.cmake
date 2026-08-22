set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ferd36/quaternions
    REF a5ef2e58b05b9b314aa21ff5b2791cd86bf241a7
    SHA512 a1e1924e7f2aa89640d02610ae9f7af820b56364d678c6d1887b51d4f13b098ff9d821ba47270beb9e6e1d4e1c5413ab61fcc432c6f6ec2881b17d79124c5389
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
