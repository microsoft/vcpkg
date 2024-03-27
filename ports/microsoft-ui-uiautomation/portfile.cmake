# portfile.cmake
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/Microsoft-UI-UIAutomation
    REF d8c87fae212678915d9b73505e188c3b63db0d79
    SHA512 4266d5f236ee7f4e2daf02177544876f025b6ec04e9ce0ad63afd0c4674ef1411865a9188d6a8a3a13b64bab1da70bebba25f03b3fc1bf39272f0c04bcbbe28f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "Microsoft-UI-UIAutomation")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)