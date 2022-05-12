vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coveooss/hareflow
    REF 341b4af04403e64f870037a987160a9233280b81 # 0.1.0
    SHA512 9a402df121731d1da5ee9490fe1e588661329fce3171282aac5d6a5afe93ece386afe838a7b20ac17e12221088a56b18611db52bb24b79c170a93ea15681cb17
    HEAD_REF main
)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(rpath "@loader_path")
else()
    set(rpath "\$ORIGIN")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "-DCMAKE_INSTALL_RPATH=${rpath}"
)
vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")