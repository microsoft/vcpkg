vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coveooss/hareflow
    REF a59406398c60d4908a9f894c187ef90370119594 # 0.1.0
    SHA512 ed9e3b54f879fed65cf7765b37951a0da04e99b09950316d9108ea35917d05b4733c5cb8f3c161e42f1baab5978affd4522e5b5028861b3f7d6cc0bfe0a40363
    HEAD_REF main
)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(rpath "@loader_path")
else()
    set(rpath "\$ORIGIN")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_INSTALL_RPATH=${rpath}"
)
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
