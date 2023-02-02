vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanosvg
    REF 03042a6297399379198f98eb625ff8902bd84784
    SHA512 163f205e81e830e8b2512ec1faa15ebaf82138fc8bd881ccfc5f19896df75e8cf77ccd20892fccd0fd3e5d6358438e6f3075fd4e6a4c4b064107451265c9f874
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

set(VCPKG_BUILD_TYPE "release") # header-only
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
