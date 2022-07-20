vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/gazebo
    REF gazebo11_11.11.0
    SHA512 0f625f71ce9c6a875ac4d694cc767735243ed20922282fb1f0ef614ddeadf35e8e08e1d8484f9dbf3c873259fae93b550742deab7954c00b055890bad2b22dff
    PATCHES
        0001-Fix-deps.patch
        fix-build-type.patch
        fix-opengl-def.patch
        add-features.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openal    HAVE_OPENAL
        ffmpeg    FFMPEG_FEATURE
        gts       GTS_FEATURE
        plugins   BUILD_PLUGINS
        tools     BUILD_TOOLS
    INVERTED_FEATURES
        simbody   CMAKE_DISABLE_FIND_PACKAGE_Simbody
        dart      CMAKE_DISABLE_FIND_PACKAGE_DART
        bullet    CMAKE_DISABLE_FIND_PACKAGE_BULLET
        libusb    NO_LIBUSB_FEATURE
        gdal      NO_GDAL_FEATURE
        graphviz  NO_GRAPHVIZ_FEATURE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_EXTERNAL_TINY_PROCESS_LIBRARY=ON
        "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        -DBUILD_TESTING=OFF  # Not enabled by default, but to be sure
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/gazebo")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/gazebo-11/gazebo/test")

foreach(postfix "" "-11")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}${postfix}/setup.sh" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}${postfix}/setup.sh" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../..")
endforeach()

vcpkg_copy_tools(
    TOOL_NAMES gazebo gz gzclient gzserver
    AUTO_CLEAN
)
set(EXTRA_OGRE_LIBS Codec_EXR Codec_FreeImage Codec_STBI OgreBites OgreMain OgreMeshLodGenerator OgreOverlay OgrePaging OgreProperty OgreRTShaderSystem OgreTerrain OgreVolume Plugin_BSPSceneManager Plugin_DotScene Plugin_OctreeSceneManager Plugin_OctreeZone Plugin_ParticleFX Plugin_PCZSceneManager RenderSystem_Direct3D11 RenderSystem_GL RenderSystem_GL3Plus)
foreach(LIB IN LISTS EXTRA_OGRE_LIBS)
    set(FILE_NAME "${CMAKE_SHARED_LIBRARY_PREFIX}${LIB}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    file(COPY "${CURRENT_INSTALLED_DIR}/bin/${FILE_NAME}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
