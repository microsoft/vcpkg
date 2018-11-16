include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/essential-moos
    REF b897ea86dba8b61412dc48ac0cfb5ff34cdaf5f6
    SHA512 7284744d211dcdcb0cd321eec96f3632ccda690e8894261f4f09a06bc8faefb2de68f4f2f755f4eeef5bb586044e98ac65cdd18c15193a1a4632bd2f4208c52f 
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)


#LIST(APPEND CMAKE_PREFIX_PATH ${CURRENT_INSTALLED_DIR} )
#find_package(MOOS REQUIRED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
#        -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=
#        -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=
#        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=


)

vcpkg_install_cmake()

## Move CMake config files to the right place
#if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
#    vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake" TARGET_PATH share/${PORT})
#else()
#	vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/MOOS" TARGET_PATH share/${PORT})
#endif()
#
#if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
#endif()
#
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/MOOS/libMOOS/Thirdparty/getpot)
#
## Put the licence file where vcpkg expects it
#file(COPY
#    ${SOURCE_PATH}/Core/GPLCore.txt
#    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
#file(RENAME
#    ${CURRENT_PACKAGES_DIR}/share/${PORT}/GPLCore.txt
#    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
#
#
