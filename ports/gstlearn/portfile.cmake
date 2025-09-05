vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstlearn/gstlearn
    REF "stable_${VERSION}"
    SHA512 51a3c0ffcff311931c03d224a08675ab91747c270f61851080a3331b1b4468f2de8cb2d262b91bd3781ed1b92153901cdfcaba47a011cb4ec3156f7662d109a7
    HEAD_REF dev
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5 USE_HDF5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstlearnd.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/gstlearnd.dll")
file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gstlearnd.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/gstlearnd.lib")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstlearn.dll" "${CURRENT_PACKAGES_DIR}/bin/gstlearn.dll")
file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gstlearn.lib" "${CURRENT_PACKAGES_DIR}/lib/gstlearn.lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
