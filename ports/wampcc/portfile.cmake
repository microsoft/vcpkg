if (VCPKG_TARGET_IS_WINDOWS)
    message("Shared build is broken under Windows. See https://github.com/darrenjs/wampcc/issues/57")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO darrenjs/wampcc
    REF 43d10a7ccf37ec1b895742712dd4a05577b73ff1
    SHA512 e830d26de00e8f5f378145f06691cb16121c40d3bd2cd663fad9a97db37251a11b56053178b619e3a2627f0cd518b6290a8381b26e517a9f16f0246d2f91958e
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        examples    BUILD_EXAMPLES
        utils       BUILD_UTILS
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF # Tests build is broken
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

if("utils" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES admin AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()
