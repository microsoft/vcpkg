vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF e7040e95c9cd13d831feed70e5d07ce06be6149d
    SHA512 54d7142f6bb81d568d0ee67af97ab443bdaca2c9ddfdb26cdb0d7afc1fb8366583aaaf34ce56bfa99dfff7559e4bfe17b48e6c07f6fd8be4cfa938fb8e35ac39
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
