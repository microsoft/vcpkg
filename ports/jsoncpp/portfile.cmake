include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 1.8.4
    SHA512 f70361a3263dd8b9441374a9a409462be1426c0d6587c865171a80448ab73b3f69de2b4d70d2f0c541764e1e6cccc727dd53178347901f625ec6fb54fb94f4f1
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
