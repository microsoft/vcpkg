# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iboB/picobench
    REF "v${VERSION}"
    SHA512 fcf0f459afa70cc7eb41fceb2485976fdceb4731652c9f3420d8b072fb1286b8afcb59d568f4693ef3f704e2fd779f134a6cce2773b1af7c47e8a3546bae0937
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/picobench/picobench.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/picobench")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
