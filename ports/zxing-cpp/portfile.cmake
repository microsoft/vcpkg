vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glassechidna/zxing-cpp
    REF e0e40ddec63f38405aca5c8c1ff60b85ec8b1f10
    SHA512 222be56e3937136bd699a5d259a068b354ffcd34287bc8e0e8c33b924e9760501b81c56420d8062e0a924fefe95451778781b2aaa07207b0f18ce4ec33732581
    HEAD_REF master
    PATCHES
        0001-opencv4-compat.patch
        0002-improve-features.patch
        0003-fix-dependency-bigint.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/FindModules/FindIconv.cmake)
# Depends on port bigint
file(REMOVE_RECURSE ${SOURCE_PATH}/core/src/bigint)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    opencv WITH_OPENCV
    iconv WITH_ICONV
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/zxing/cmake TARGET_PATH share/zxing)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/zxing.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
else()
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/zxing DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/zxing)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/zxing)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
