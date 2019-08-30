include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/zfp
    REF 0.5.5
    SHA512 c043cee73f6e972e047452552ab2ceb9247a6747fdb7e5f863aeab3a05208737c0bcabbe29f3c10e5c1aba961ec47aa6a0abdb395486fa0d5fb16a4ad45733c4
    HEAD_REF master
    PATCHES
       fix-cfp-install.patch
       fix-test-install.patch
)

set(BUILD_CFP OFF)
if("cfp" IN_LIST FEATURES)
   set(BUILD_CFP ON)
endif()

set(BUILD_TESTING OFF)
if("test" IN_LIST FEATURES)
   set(BUILD_TESTING ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DBUILD_CFP=${BUILD_CFP} 
      -DBUILD_TESTING=${BUILD_TESTING} 
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
   vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)