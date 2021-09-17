vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF 576d169463c7f9990045fd9223f5cf688150def0 #RELEASE_1.1.3
    SHA512 376db117df3ab48a6471d7004fc77fb8bd9b5d9dfaff53675f1bd99c8bc9bec7cadcefbd7116b206ef4703b9146cf097ad3b8aadff36b66302f1c82e8e1fa988
    HEAD_REF master
)

if (VCPKG_TARGET_IS_UWP)
  set(USE_WINDOWSSTORE ON)
else()
  set(USE_WINDOWSSTORE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DWINDOWSSTORE=${USE_WINDOWSSTORE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)