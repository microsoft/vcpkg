vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v11.0.1
    SHA512 22247e80d9e5710ce69ebac4327f8d632db5bdfe46121d5d3166ab8badd430742f21e559244baca3dc6e50260399d8a9dc8c56b390ca0549955c85212babc635
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROCXX=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(TARGET reproc reprocxx)
    vcpkg_fixup_cmake_targets(
        CONFIG_PATH share/${TARGET} 
        TARGET_PATH share/${TARGET}
    )
    
    file(
        INSTALL ${SOURCE_PATH}/LICENSE 
        DESTINATION ${CURRENT_PACKAGES_DIR}/share/${TARGET}
        RENAME copyright
    )
endforeach()
