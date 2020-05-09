# TODO
# 1. change:
#   - HEAD_REF to master
#   - REF and SHA512 to the release version (remember to push to master the develop with release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/popsift	
#    REF v1.0.0-rc1
    # REF 318ae82
    REF 73e5e08a23b351a5f4c69f59d28bfda8496f1598
    # SHA512 5e9ee211d2f35189a7a284b5fcd47fca56d69ecaef5a13ffa9babd4d9e91eb02b596df10846366417031e2291bf468c5160dd7b622bb51fdfab672ee4f1517f2
    SHA512 e9a21b48450efe2abbcdb6ca1be1e11f3d3575fa3085f463cdaca5196cb2999a2da4bb7ed2a0a438fbc47e3ba64592a3e49f2f901eef1a29ce69f711185eb702
#    HEAD_REF develop
    HEAD_REF ci/win/addDebug
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    apps       PopSift_BUILD_EXAMPLES
)

# if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    set(PopSift_USE_STATIC_LIBS ON) 
#    # set(POPSIFT_PIC OFF)
# else()
#     set(PopSift_USE_STATIC_LIBS OFF) 
#    # set(POPSIFT_PIC ON)
# endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} 
#     -DPopSift_BOOST_USE_STATIC_LIBS:BOOL=${PopSift_USE_STATIC_LIBS}
# #        -DPopSift_USE_POSITION_INDEPENDENT_CODE:BOOL=${POPSIFT_PIC}
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