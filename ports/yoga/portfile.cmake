include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds not supported yet.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/yoga
    REF a04a6b5e8f2f02a2c4b57af726f8ef116e03d7a6
    SHA512 dc86c1280089f736055f368fbe913ab98671a61aa54d9b544052c8da6d16e7e014f4c7a9a259f34aeb70e12baf8f96680757eeb0b92ee96ebbe4d22dc3eb5613
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_cmake()

file(INSTALL ${SOURCE_PATH}/yoga DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/yogacore.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/yogacore.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/yoga RENAME copyright)