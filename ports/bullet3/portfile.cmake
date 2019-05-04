include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bulletphysics/bullet3
    REF 2.87
    SHA512 649e470223295666eda6f7ff59d03097637c2645b5cd951977060ae14b89f56948ce03e437e83c986d26876f187d7ee34e790bc3882d5d66da9af89a4ab81c21
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON
        -DBUILD_DEMOS=OFF
        -DBUILD_CPU_DEMOS=OFF
        -DBUILD_BULLET2_DEMOS=OFF
        -DBUILD_BULLET3=OFF
        -DBUILD_EXTRAS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DINSTALL_LIBS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/bullet/BulletInverseDynamics/details)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/bullet3 RENAME copyright)
