include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_find_acquire_program(PYTHON2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF b4b0854f6b9213b5250e8ce78301aa287a31a947 # 0.29.0
    SHA512 f5fd199448a5d996dd3aa5178bd7e2e4d298823c15fe5f3f24f309d0db7ce93055d041fe504b089e0e0cd106b2ddb532f89a1a2f4e76d6d3708d82b3432050b1
    HEAD_REF next
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYTHON_EXECUTABLE=${PYTHON2}
        -DENABLE_JSONCPP=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(GLOB SHARE_DIR ${CURRENT_PACKAGES_DIR}/share/*)
file(RENAME ${SHARE_DIR} ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake/tmp)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/tmp)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/Proton ${CURRENT_PACKAGES_DIR}/lib/cmake/tmp/Proton)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/Proton ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/tmp/Proton)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/tmp/Proton TARGET_PATH share/proton)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ProtonCpp TARGET_PATH share/protoncpp)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt
            ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/qpid-proton/examples)
