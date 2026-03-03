if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
     list(APPEND PATCHES fix_static_builds.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ki18n
    REF "v${VERSION}"
    SHA512 418aee5a836fcdb7a8901282c256e8bdb3ff1f1f346c882feb548b9ef39951ff1709dd2ac924e281441d86c7744e086ca82178f952dbb24173aab910d336d7e4
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_find_acquire_program(PYTHON3)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qml
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5I18n)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

# The following pattern has an absolute path, but is still ultimately relocatable, so skip absolute paths check:
# share\KF5I18n\KF5I18nMacros.cmake
# # The Python executable used for building ki18n will be used as a fallback
# # solution if it cannot be found in $PATH when building applications.
# set(_KI18N_PYTHON_EXECUTABLE "C:/Dev/vcpkg-downloads/tools/python/python-3.10.7-x64/python.exe")
#
# find_program(KI18N_PYTHON_EXECUTABLE NAMES python3 python2 python)
# if(NOT KI18N_PYTHON_EXECUTABLE)
#     set(KI18N_PYTHON_EXECUTABLE "${_KI18N_PYTHON_EXECUTABLE}")
# endif()
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
