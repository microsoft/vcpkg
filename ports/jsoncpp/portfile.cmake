include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 1.9.2
    SHA512 7c7188199d62ae040d458d507ba62f0370c53f39c580760ee5485cae5c08e5ced0c9aea7c14f54dfd041999a7291e4d0f67f8ccd8b1030622c85590774688640
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
