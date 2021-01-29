
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/protozero
    SHA512 24bab4bf4ff7c67b4f2d8e97919ccde115db4fa476462926102da2f48b4689d6b454df56dbc30754d0e81c37f669535e4b2101033b079ace0f4ea2706447abe1
    REF v1.6.8
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug")
file(COPY ${SOURCE_PATH}/include/protozero DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)