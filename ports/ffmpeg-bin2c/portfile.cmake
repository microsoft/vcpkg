set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)  # host tool for building ffmpeg

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ffmpeg/ffmpeg
    REF "n${VERSION}"
    SHA512 e858e92e5eb08d562302cde371af55917df6e1fe53994e18462a3c929a40ede1828c2bd53c2a7d65a2cfd791782ead3cd94efb2def904f49cb5dd8ab5cd4256f
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/ffbuild")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/ffbuild"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LGPLv2.1")
