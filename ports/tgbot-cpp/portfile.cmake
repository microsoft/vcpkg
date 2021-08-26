vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.2.1
  SHA512 b094f9c80dd15b7930b7d7250169b3199d9c84b84826adececa8237111f5ba384ec790dbe969999f362ca2fb35b93950d053777ce5f167007e33c3e4eb133453
  HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
