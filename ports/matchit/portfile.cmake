vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BowenFu/matchit.cpp
    REF v1.0.0
    SHA512 af7d9ea34a62a484065193d83716c9f3a0dcd5f9a8b0a151501f438fccdc6f80772b83651024ddf434c819ec34e041a3d33c8043c91ed89879620d396ba35bc8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
