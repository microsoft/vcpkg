vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ftylitak/qzxing
    REF "v${VERSION}"
    SHA512 21ab9960fafc5eb5e2907e22e31d29d9b4db66480e65ba26d86bededa708d51abc2fd1a9e959357402104e993653dc4aa9a6e6fcf9de362a74030c8bddad8411
    HEAD_REF master
    PATCHES
        use-qt6.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            build-shared-lib.patch
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        -DQZXING_MULTIMEDIA=OFF
        -DQZXING_USE_QML=OFF
)

vcpkg_cmake_build(TARGET qzxing)

file(INSTALL "${SOURCE_PATH}/src/QZXing.h"
             "${SOURCE_PATH}/src/QZXing_global.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qzxing${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qzxing${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()
else()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qzxing${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
