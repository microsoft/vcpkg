vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d-bahr/CRCpp
    REF "release-${VERSION}"
    SHA512 61d6d4636cbf42752568900a1267336721836b80cbe99e1795c74be9fffd9d6368697182565beecf5b4050d649c7a77acbacfac2a20eff9de4073dab4ea073cf
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
        -DBUILD_DOC=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
