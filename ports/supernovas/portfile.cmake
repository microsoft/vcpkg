vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Smithsonian/SuperNOVAS
    REF "v${VERSION}"
    SHA512 84492906766fdac531628bf5eadeabab20c6c5d822bb5bd7f9cacb5bdcbea548d1392f8cb68079d52768d359dc1f7b8530a6642850f2851e52d51cd8a3b38e8e
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp              ENABLE_CPP
        solsys-calceph   ENABLE_CALCEPH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DENABLE_CSPICE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

set(debug_pc "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/supernovas.pc")
if(EXISTS "${debug_pc}")
    vcpkg_replace_string("${debug_pc}" "-lsupernovas " "-lsupernovasd ")
    if("cpp" IN_LIST FEATURES)
        vcpkg_replace_string("${debug_pc}" "-lsupernovas++ " "-lsupernovas++d ")
    endif()
    if("solsys-calceph" IN_LIST FEATURES)
        vcpkg_replace_string("${debug_pc}" "-lsolsys-calceph " "-lsolsys-calcephd ")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# SOFA is intentionally not cited: SuperNOVAS describes this as a modified implementation
# that is neither provided nor endorsed by SOFA.
# https://github.com/Sigmyne/SuperNOVAS/blob/eafc3120cf257d643bd0676573420141ce8e53a6/src/c99/refract.c#L411-L423
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
