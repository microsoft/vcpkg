vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daleabarnard/try-catcher
    REF 1.0.0
    SHA512 ef544016e65c0370143bf3a2a71578b28ad9cfa2fe2f1ace0f68bd62314382cff3dd6033a7059024c153d3f5f3bf84b5a50498bfd7a7de0c6bb2b9d430cde4e6
    HEAD_REF main
)

# This is a header-only modern C++ package.
file(INSTALL "${SOURCE_PATH}/TryCatcher.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
