include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 1.8.1
    SHA512 4203826fca4c366b51d28ffc928399c914ffaba8be1cada64ff118b5742e6b469d3fc3e59344587d851447857b479794c5697d4fd11a9a55b32a3a7a801b745b
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
    OPTIONS -DJSONCPP_WITH_CMAKE_PACKAGE:BOOL=ON
            -DBUILD_STATIC_LIBS:BOOL=${JSONCPP_STATIC}
            -DBUILD_SHARED_LIBS:BOOL=${JSONCPP_DYNAMIC}
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
