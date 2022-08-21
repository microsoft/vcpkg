vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/UVAtlas
    REF jul2022
    SHA512 fe857766d598c73badba6eda3128775f9195d0a1a7658e9b48a77dd631da4bbd31ab946bc98f8e9b229a6bc99a785ac3da693cb655be0f6a1393ad176e26b688
    HEAD_REF main
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        eigen ENABLE_USE_EIGEN
)

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/uvatlas)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("eigen" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    UVATLASTOOL_EXE
    URLS "https://github.com/Microsoft/UVAtlas/releases/download/jul2022/uvatlastool.exe"
    FILENAME "uvatlastool-jul2022.exe"
    SHA512 3c1f7d25f10a85895d75d4102e127af857c4eae1bb3773b84e0f48e30ba9be517469b1a7504c6859e5b75481fea427052af21f3491f6993bf3dc360829c086b8
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/uvatlas/")

  file(INSTALL
    ${UVATLASTOOL_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/uvatlas/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool-jul2022.exe ${CURRENT_PACKAGES_DIR}/tools/uvatlas/uvatlastool.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES uvatlastool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
