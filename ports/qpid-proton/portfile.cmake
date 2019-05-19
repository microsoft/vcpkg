include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_find_acquire_program(PYTHON2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF 0.28.0
    SHA512 dc253218a076ea56d64e0aaeb6ef9e7345bb9ac700c58b8ea6cb9b3c79d66b0667bcc62cbb45f9ce3455fa8f97b7dfb1c2096d269d1b5b9c5c650ef61a126cfe
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
