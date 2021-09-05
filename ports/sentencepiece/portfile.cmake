if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF v0.1.95
    SHA512 22484cf0311315e25a3184561f4e18b45286ad068bfb722c860e1b44fb16913c96d34723b486fab5e4e1e69f4b620a0e3cff410f56cb6561a67193ebaf565a31
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPM_ENABLE_SHARED=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
if(NOT VCPKG_CMAKE_SYSTEM_NAME)
   file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece.lib ${CURRENT_PACKAGES_DIR}/debug/lib/sentencepieced.lib)
   file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_train.lib ${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_traind.lib)
endif()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
