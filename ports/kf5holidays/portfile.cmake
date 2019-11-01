include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kholidays
    REF v5.64.0
    SHA512 a4d9a88bb12b89c636ac63d848505c7895c672ef0e540e7fa45de22fb085048fa5f76729be60fceafbe63ab4b325251fdc65f36b58ab6d9bae7f50678578d4c8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Holidays)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qml ${CURRENT_PACKAGES_DIR}/debug/qml )
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qml ${CURRENT_PACKAGES_DIR}/qml )

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5holidays RENAME copyright)
