#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asklar/xaml-islands
    REF 0.0.15
    SHA512 055e68ef688089b20f8eef6c2e0a3c2bf2012d0466d4e827ff4628e1a97c65e270481dfa39aaeb9765f0df25f88102162e1253e04f60cbb3b40c0c228d71507c
    HEAD_REF main
)

file(INSTALL ${SOURCE_PATH}/inc/cppxaml DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
