vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 6aba23f4a8628d599a9ef7fa4811c4ff6e4070e2 # 1.9.3
    SHA512 f056110b22b7899a9e2cce1c1bdce13eb54750fe9308331bb7edb0f3f21373f285fcb304d66ddf0d48c80b70c68d8122221208b54ad0666816afae750a614e08
    HEAD_REF master
    PATCHES
        allow-disable-examples.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(JSONCPP_STATIC ON)
else()
    set(JSONCPP_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DJSONCPP_WITH_CMAKE_PACKAGE=ON
        -DBUILD_STATIC_LIBS=${JSONCPP_STATIC}
        -DJSONCPP_WITH_PKGCONFIG_SUPPORT=OFF
        -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF
        -DJSONCPP_WITH_TESTS=OFF
        -DJSONCPP_WITH_EXAMPLE=OFF
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
