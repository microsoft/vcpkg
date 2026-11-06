
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/soqt
    REF v1.6.4
    SHA512 015888f48b0246fd2fffb54d1d7c96ce0cbdf360fc0130257be9fcdbc320bd2af5289c31febdf873bcb68df6d9e823e98115af79f4b081394c080f1ef7c15710
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOANYDATA_SOURCE_PATH
    REPO coin3d/soanydata
    REF 7ee364a6ec2b496b28e5a13a88800ad11fcbe84e
    SHA512 3ad76b7652004bc7f0dd76b9a5ee45d4c442d18ac44b82df4f49bbf375e181594a03037b3bd5d177c66af7379870af831117d57e93f0fcf6d58c72ecb1c98c42
    HEAD_REF master
)

if(NOT EXISTS "${SOURCE_PATH}/data/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/data")
    file(RENAME "${SOANYDATA_SOURCE_PATH}" "${SOURCE_PATH}/data")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOGUI_SOURCE_PATH
    REPO coin3d/sogui
    REF 426cd49f3e4598ff96da50e521867b9fe550fd99
    SHA512 defdeb37c22aaea33a2d0178050a9f0ed0807302bee7abb2ae1a1b122a49fe588f9c16c94d75bb94d767b64ad3cf1bd552985c609ff28f60f0d74c51880e553b
    HEAD_REF master
)

if(NOT EXISTS "${SOURCE_PATH}/src/Inventor/Qt/common/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/Inventor/Qt/common")
    file(RENAME "${SOGUI_SOURCE_PATH}" "${SOURCE_PATH}/src/Inventor/Qt/common")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOQT_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOQT_BUILD_DOCUMENTATION=OFF
        -DSOQT_BUILD_SHARED_LIBS=${SOQT_BUILD_SHARED_LIBS}
        -DSOQT_USE_QT6=ON
        -DSOQT_USE_CPACK=OFF
        -DSOQT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SoQt-1.6.4)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
