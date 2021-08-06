if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF v0.1.82
    SHA512   669d6a1e86c44587d725b1e93f11b707e510a180dec08afb79268158f5de009cb20ffccc72c501c84f032360e52e53ae227504f3538f59978629433e0d6fcf65
    HEAD_REF master
    PATCHES rename-version.patch
)
file(RENAME "${SOURCE_PATH}/VERSION" "${SOURCE_PATH}/VERSION.txt")

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
