vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/ncnn
    REF 20220420
    SHA512 7c567bcd75cf36be7fbb16dba7f978ae965478afed8948e9e1c6f8c681ea678f769e64fae337a5c1d0bc1549bf922c1761b51a7822153a1eb4d267ef8adf1ecd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNCNN_BUILD_TOOLS=OFF
        -DNCNN_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ncnn)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shapelib")
    file(COPY ${EXES} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shapelib")
    file(REMOVE ${EXES})
endif()

file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(DEBUG_EXES)
    file(REMOVE ${DEBUG_EXES})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
