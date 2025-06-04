vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gstlearn/gstlearn
    REF "stable_${VERSION}"
    SHA512 0
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

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstlearnd.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/gstlearnd.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstlearn.dll" "${CURRENT_PACKAGES_DIR}/bin/gstlearn.dll")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
