vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF v0.1.0-alpha1
    SHA512 d37eea194b0352a08dd89ac7622bdd6224312ad48a31d8ab36627a8aaff5e795e3513ad010eed516703f6da842a95119c1a4a290b145a43e91ff80a37fff8676
    HEAD_REF master
)

if("cpprestsdk" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_UWP)
    set(USE_CPPRESTSDK true)
else()
    set(USE_CPPRESTSDK false)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DUSE_CPPRESTSDK=${USE_CPPRESTSDK}
        -DWALL=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${SOURCE_PATH}/third-party-notices.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/microsoft-signalr)

vcpkg_copy_pdbs()