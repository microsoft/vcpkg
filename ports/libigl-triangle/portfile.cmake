
set(TRIANGLE_VERSION 1.6)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/triangle
    REF  d284c4a843efac043c310f5fa640b17cf7d96170
    SHA512 0f2377663e84dfbbf082d13af6d535ae7e6c22655f8f1a34a9e7bc657edcf0ad7fd991e42afb11c750548579c7b637d179a818092b408e9df4b59338a28e6bbf
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/triangle.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
