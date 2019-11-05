vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gadomski/cpd
    REF 1f3637e96f755957eab529c7eb15334f04fb6d19 #version 0.5.1 commit on 2019.03.26
    SHA512 349edb7995a8790736465b0b56c5e7bd3167b7cd54ac8f07e62a238e2638f43c30c0a11aae289dac005a2840c8440158c1f2bda10b14e2fbaee82dfaf34525ae
    HEAD_REF master
    PATCHES 
        Fix-FindJsoncpp.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
    
