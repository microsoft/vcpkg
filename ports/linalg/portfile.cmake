#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sgorsten/linalg
    REF v2.1
    SHA512 48d8248ea1bca3d4fe35d038690f496cd0c8c9469d76eca684668ce6fef5df0eb9556f9b49e4da90e2c2e8ef475791877aa815c3f9437c097fbfc303134d02d7
    HEAD_REF master
)

configure_file(${SOURCE_PATH}/UNLICENSE ${CURRENT_PACKAGES_DIR}/share/linalg/copyright COPYONLY)
configure_file(${SOURCE_PATH}/linalg.h ${CURRENT_PACKAGES_DIR}/include/linalg.h COPYONLY)