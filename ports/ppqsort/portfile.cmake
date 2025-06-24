set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GabTux/PPQSort
    REF "v${VERSION}"
    SHA512 404621a489cc530170196dca317cabf35ecb2f93e10465474a5af1a4e79352433ca57711236f1cc08a359ae40294d9dd62feed42ec1f6890fa5139473997c29c
    HEAD_REF master
    PATCHES
        remove-cpm.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO TheLartians/PackageProject.cmake
    REF "v1.11.1"
    SHA512 cffd7b203c54f325b4604b909678425e0f63bed3f9d4fb5478b1eb885b532e682d3972595d0909ea2feb1aadd73736bd282931fa62fa47af27affb6b3f17a304
    HEAD_REF master
)
file(RENAME "${PACKAGE_PROJECT_PATH}" "${SOURCE_PATH}/cmake/packageproject.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp PPQSORT_USE_OPENMP 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/PPQSort-${VERSION}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
