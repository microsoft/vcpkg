vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qtrest/qtrest
    REF ${VERSION}
    SHA512 2bdbbdde7c4f7a27943c93a2a26abe89e087e6b7c32d0e481422a8ad3e78c66c6921ef00c1cbf17f3b61db8a678685371c819218d10576ac9ec1548262415c04	
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml WITH_QML_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TYPE=${BUILD_TYPE}
        -DBUILD_EXAMPLE=0
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
