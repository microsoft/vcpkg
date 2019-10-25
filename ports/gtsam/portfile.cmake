vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF be74732a091ca3ed8a95bb6f98331b7a52b19161
    SHA512 4519195254e34e66e5aae6bb4eb423b80128284317eb24ecf26e11dadb6656ab8a99bc57c0dc8ff5f518a573d989189af435b4cad1e9414171b176c23af1e1c8
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
