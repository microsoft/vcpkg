vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/sonnet
    REF v5.73.0
    SHA512 3efe90af98a1ae31617aa28c86f1d8da3120997d391a1b29c35840e6ca133d8c8ce3df30e4767153553b3d1355e5c84a98c71ed02135ae1d91fc8a039efa988d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_PLUGINDIR=plugins
            -DKDE_INSTALL_DATAROOTDIR=data
            -DKDE_INSTALL_QTPLUGINDIR=plugins
)

vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/bin)
vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet)

file(RENAME ${CURRENT_PACKAGES_DIR}/bin/gentrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet/gentrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/parsetrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet/parsetrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX})

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Sonnet)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5sonnet)
file(APPEND ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet/qt.conf "Data = ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/data")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gentrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/parsetrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX})

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
