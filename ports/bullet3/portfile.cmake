vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bulletphysics/bullet3
    REF 3.22
    SHA512 edacf643ca9621523812effe69a7499716bc65282c58c1f5b4eb4f17b2b1ab55a4f71b06a73483f57e57a5b032c234d09ba5fab9881321f2cbc3c27b43fdc95d
    HEAD_REF master
    PATCHES
        cmake-fix.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        multithreading       BULLET2_MULTITHREADING
        double-precision     USE_DOUBLE_PRECISION
    INVERTED_FEATURES
        rtti                 USE_MSVC_DISABLE_RTTI
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
        -DBUILD_CPU_DEMOS=OFF
        -DBUILD_BULLET2_DEMOS=OFF
        -DBUILD_OPENGL3_DEMOS=OFF
        -DBUILD_BULLET3=OFF
        -DBUILD_EXTRAS=ON
        -DBUILD_BULLET_ROBOTICS_GUI_EXTRA=OFF
        -DBUILD_BULLET_ROBOTICS_EXTRA=OFF
        -DBUILD_GIMPACTUTILS_EXTRA=OFF        
        -DBUILD_UNIT_TESTS=OFF        
        -DINSTALL_LIBS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME bullet CONFIG_PATH share/bullet)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/bullet/BulletInverseDynamics/details")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
