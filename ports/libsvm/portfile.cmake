vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/libsvm
    REF v325
    SHA512 D5323B128DFCDC7F64B2161E70FA7999C0A93D47C90B366BE066AA01EA92B5817F04812DEF2E05469DEE1F26C6A83DA5E50EEAE3F50B4062D9B24AC0944C6203
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
    if(WIN32)
        vcpkg_copy_tools(TOOL_NAMES svm-predict svm-scale svm-toy svm-train AUTO_CLEAN)
    else()
        vcpkg_copy_tools(TOOL_NAMES svm-predict svm-scale svm-train AUTO_CLEAN)
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
