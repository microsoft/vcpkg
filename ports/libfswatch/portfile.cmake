vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF 9576be71b18d769938883890550654e018a323b1
    SHA512 a7049b694b993e5ff5c1e8cd227de54b5df2ca7473e896f1094246c5d66c59bff3f3fe2edd08afa7724f7de43b555c120c16cf927ff5defe042aacb9a0ffc91f
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)
