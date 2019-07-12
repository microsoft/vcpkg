include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 645250b6690785be60ab6780ce4b58698d884d11
    SHA512 a115d64771deafa06ace3b40ea3c0ef65a03cbf7b855f832853e40f57d464a257ea0bfca3875fc25b0a483ab8b8e38c42c188bc9d41d02f99681fe1e3aecba9f
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(JSONCPP_STATIC OFF)
    set(JSONCPP_DYNAMIC ON)
else()
    set(JSONCPP_STATIC ON)
    set(JSONCPP_DYNAMIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS -DJSONCPP_WITH_CMAKE_PACKAGE:BOOL=ON
            -DBUILD_STATIC_LIBS:BOOL=${JSONCPP_STATIC}
            -DJSONCPP_WITH_PKGCONFIG_SUPPORT:BOOL=OFF
            -DJSONCPP_WITH_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

# Fix CMake files
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/jsoncpp)

# Remove includes in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncpp/copyright)

# Copy pdb files
vcpkg_copy_pdbs()
