include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zuhd-org/licensepp
    REF 06e0c35fb300677a292bb2d4e83cbcad8f0c5b99
    SHA512 e5f24d12299dbae46060f7898c8e5f268135a2bffcbac214734182b85d17bc3d8fc0fc36301068b04a8ce6ad80c75aa283253c78106d142d6b86a04d7606616a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dtest=OFF
        -Dtravis=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

#file(REMOVE_RECURSE
#    ${CURRENT_PACKAGES_DIR}/debug/include
#    ${CURRENT_PACKAGES_DIR}/debug/share
#)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/xeus/xeus.hpp
#        "#ifdef XEUS_STATIC_LIB"
#        "#if 1 // #ifdef XEUS_STATIC_LIB"
#    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
