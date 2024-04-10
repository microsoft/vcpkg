vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SymCrypt
    REF "v${VERSION}"
    SHA512 213b45f4767450f6be0e00fb3bad419cba2a762c13ca868b4376269093e2d552504740140b5988b2aac024b275d75456b547927ee142fe3db06630934bbea5d3
    HEAD_REF main
    PATCHES
        cmake_build_dir.patch
)

# git branch --show
set(ENV{SYMCRYPT_BRANCH} "v${VERSION}")
# git log -1 --format=%h
set(ENV{SYMCRYPT_COMMIT_HASH} "a84ffe1")
# git log -1 --date=iso-strict-local --format=%cd
set(ENV{SYMCRYPT_COMMIT_TIMESTAMP} "2024-01-27T08:00:47+02:00")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
