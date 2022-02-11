# Single-file header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO k06a/boolinq
    REF 0df37ed90570a148c9d2395f5066313fd59247c9 #v3.0.4
    SHA512 c1c23cf4e3c3f2a02a6c6ea59faf1eb223fe0a6ba840b4f306671e3e866bfd156d0a7a46542b684eeba3d9c744d678c48d4f1d7471f07fb7f1ba0bb8812f548f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/boolinq/boolinq.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/boolinq")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
