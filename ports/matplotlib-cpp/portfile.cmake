# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lava/matplotlib-cpp
    REF 70d508fcb7febc66535ba923eac1b1a4e571e4d1
    SHA512 4da452fc38b6c349a1b08b97775ef2d90354fabd3c8c3a0383f08609b22dea222b7f3e091efc1b833755f6b5c1e8564e675d2ed54cdc21f8b07b1b7bb44a82f4
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/matplotlibcpp.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
