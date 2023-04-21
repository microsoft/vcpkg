vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bulletphysics/bullet3
    REF "${VERSION}"
    SHA512 7086e5fcf69635801bb311261173cb8d173b712ca1bd78be03df48fad884674e85512861190e45a1a62d5627aaad65cde08c175c44a3be9afa410d3dfd5358d4
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
    SOURCE_PATH "${SOURCE_PATH}"
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
