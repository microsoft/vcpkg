set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)  # host tool for building ffmpeg

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ffmpeg/ffmpeg
    REF "n${VERSION}"
    SHA512 4327d259b2ed9cc35a6139606643bf9c9db5fb0372a9eb259fed61af50505a2b59f0c3d94c51fec89d2e0cd552a413c5f50514683931c94c429824198d56ec56
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/ffbuild")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ffbuild"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/ffbuild/bin2c.c")
