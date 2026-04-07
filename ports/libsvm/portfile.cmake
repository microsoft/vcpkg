
string(REPLACE "." "" LIBSVM_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/libsvm
    REF "v${LIBSVM_VERSION}"
    SHA512 b05d1153c17bb585495785372810807ff695afbda23dd88ecb67a282d7c752068e2a0f6fa779aca2132c6bf3396bdf10b97665849e4aae4c76de98c2f095beab
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools SVM_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSVM_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}" CONFIG_PATH "share/unofficial-${PORT}")

if("tools" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_copy_tools(TOOL_NAMES svm-predict svm-scale svm-toy svm-train AUTO_CLEAN)
    else()
        vcpkg_copy_tools(TOOL_NAMES svm-predict svm-scale svm-train AUTO_CLEAN)
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
