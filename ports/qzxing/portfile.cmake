vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ftylitak/qzxing
    REF "v${VERSION}"
    SHA512 21ab9960fafc5eb5e2907e22e31d29d9b4db66480e65ba26d86bededa708d51abc2fd1a9e959357402104e993653dc4aa9a6e6fcf9de362a74030c8bddad8411
    HEAD_REF master
    PATCHES
        use-qt6.patch
        allow-shared-build.patch
)

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
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qzxing.lib"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qzxing.pdb"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing.lib"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qzxing.pdb"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()
else()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}qzxing${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}qzxing${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QZXING_BUILD_SHARED_LIBS)
configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
