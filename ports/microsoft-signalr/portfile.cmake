vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF v0.1.0-alpha1
    SHA512 1677b4c4eefc77f35e60d19153a386992001edfdaa8f629fe7a3d1aed025ed8bdd04e7a5a4560716e8d57c47e44e3e933835d1ebf67aad6670a892c725c63686
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