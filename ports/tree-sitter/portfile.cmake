vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "SamuelMarks/${PORT}"
    REF             af293c7765d41836b0f55cae181c39199c36b9ff
    SHA512          0a5b84ec31c9c40a2ce6ce5adecb38f3f5faeae6d8aa3266b115b8340af6117201a81aa75b10f3e0bc765222b2b34837b116477d7af7cce01edcf3cc25502fbf
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
