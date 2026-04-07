# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ben-strasser/fast-cpp-csv-parser
    REF 75600d0b77448e6c410893830df0aec1dbacf8e3
    SHA512 aab418e98eb895dabd6369b186b7a55beddb84b89e358395a9f125829074916eff9086d80f9cd342d1bfd91acacc7103875c970a84164b75fff259cc93729285
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/csv.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
