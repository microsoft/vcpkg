vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO neiljed/vtflib
    REF f116d937226734a898c8b78606ff9a21fc585023 # 1.3.2
    SHA512 31b0ddfede1a66924ceaaebd114b4b3d223ca822ab124f1ea42ee70766190c173eb48594df427e2d0eabf2fd3c37d19a1d88015d7331fc26e832f32ca8579411
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/VTFLIBConfig.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH /lib/cmake/vtflib)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)