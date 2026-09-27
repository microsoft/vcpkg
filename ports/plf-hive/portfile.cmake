set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_hive
    REF aa47e3627a08251d6df2103ddc3be482eb9fa5b3 # commit date: 2026-09-06
    SHA512 5e5660574575f7f0f5cae735e1b64922ada8f6cf9ae1cb5eb4f29039d4e0415a79241a0e00a63dd63cf654d55cba143fb370b2ec9d838428af25291794997d0d
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/plf_hive.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
