# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/hedley
    REF 4a59eb6d8e3e73b6c60aed2c92a6590d26df93d8
    SHA512 64a4452170a37e05134d02eb75dad38c410ed21f96cab3c6100e8f64b13c4daf40b916e0b5fee731ef9e318fbd628ee692ad6681e4f258d5f86b3e037ed83f8d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/hedley.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(STRINGS ${SOURCE_PATH}/hedley.h SOURCE_LINES)
# Capture more lines than required to handle future license file changes
list(SUBLIST SOURCE_LINES 0 30 SOURCE_LINES)
list(JOIN SOURCE_LINES "\n" _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}")
