vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDDockWidgets
    REF 9990300006854afa4b4fa796912da067e770046a 
    SHA512 2207b3c021957d9be8652cad24c0b5e37b07fa02ffeeeb7dab57feaeade7973b580b853d6b69db15015b62cc1397459e27d032131292baaeb17a0633e287fa3c 
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DKDDockWidgets_QT6=ON
        -DKDDockWidgets_STATIC=${KD_STATIC}
        -DKDDockWidgets_QTQUICK=OFF
        -DKDDockWidgets_PYTHON_BINDINGS=OFF
        -DKDDockWidgets_EXAMPLES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/KDDockWidgets-qt6" TARGET_PATH "share/KDDockWidgets-qt6")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
