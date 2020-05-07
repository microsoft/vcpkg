# TODO
# 1. change:
#   - HEAD_REF to master
#   - REF and SHA512 to the release version (remember to push to master the develop with release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/popsift	
#    REF v1.0.0-rc1
    REF 318ae82
    SHA512 5e9ee211d2f35189a7a284b5fcd47fca56d69ecaef5a13ffa9babd4d9e91eb02b596df10846366417031e2291bf468c5160dd7b622bb51fdfab672ee4f1517f2
#    HEAD_REF develop
    HEAD_REF ci/win/addDebug
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    apps       PopSift_BUILD_EXAMPLES
)

#if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    set(POPSIFT_PIC OFF)
#else()
#    set(POPSIFT_PIC ON)
#endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
#        -DPopSift_USE_POSITION_INDEPENDENT_CODE:BOOL=${POPSIFT_PIC}
#    OPTIONS_RELEASE -DCMAKE_BUILD_TYPE:STRING=Release
#    OPTIONS_DEBUG -DCMAKE_BUILD_TYPE:STRING=Debug
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/PopSift)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

 # move the bin direcory to tools
 if ("apps" IN_LIST FEATURES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" ${CURRENT_PACKAGES_DIR}/tools/popsift)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
#    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" ${CURRENT_PACKAGES_DIR}/tools/popsift/debug)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/popsift)
 endif()

file(INSTALL ${SOURCE_PATH}/COPYING.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/popsift RENAME copyright)