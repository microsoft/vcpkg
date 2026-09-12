vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 d70a177238c818c0403689ae12720e9c155e4d1f2025464926e3674ba882be39b0ce2a7c39946447ff2ba2bd604cacbcc48d949a1020898b9bbf97b1df58ad80
    HEAD_REF master
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
