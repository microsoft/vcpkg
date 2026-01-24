# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iboB/picobench
    REF "v${VERSION}"
    SHA512 2c516c56fa558c395549c3c8daf5cc29fd2cae5e5af00d5b5e079b15f472979db6c4edf078e294715a2fb12d6ad8ba1dc5fe216e2de837a290bb418e0f78d166
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/picobench/picobench.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/picobench")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
