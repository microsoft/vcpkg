include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF 3.2.3
    SHA512 4224b22e30f1b15328bc3a6fbbc079470a71ac2e62abb23806b89ebe40d0c795538d73f6cc173cba44b3e2cec85e6e974c0fed5dc23b4556aa09c85bce57bbd4
    HEAD_REF master
    PATCHES 
        fix-c2280-error.patch
        fix-boost-issue.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGTSAM_USE_QUATERNIONS=OFF
        -DGTSAM_POSE3_EXPMAP=OFF
        -DGTSAM_ROT3_EXPMAP=OFF
        -DGTSAM_ENABLE_CONSISTENCY_CHECKS=OFF
        -DGTSAM_WITH_TBB=OFF
        -DGTSAM_WITH_EIGEN_MKL=OFF
        -DGTSAM_WITH_EIGEN_MKL_OPENMP=OFF
        -DGTSAM_THROW_CHEIRALITY_EXCEPTION=OFF
        -DGTSAM_INSTALL_MATLAB_TOOLBOX=OFF
        -DGTSAM_BUILD_WRAP=OFF     
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
