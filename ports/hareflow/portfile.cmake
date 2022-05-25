vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coveooss/hareflow
    REF 5cee9e3a7dbc5e205103595860e221d9258174d1 # 0.1.0
    SHA512 a726c83c38fcab986802fe9441c206efa6a21638a3223b2f8ec8e50970013c4eed8234000f6a387f6f2318be3f60767e86071a3ff554380ec69f2c05059c8abc
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