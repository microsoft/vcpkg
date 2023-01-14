vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF v1.1.5
    SHA512 10aed7452eaf95c785899086118181615d29496d9f6e5b7054005b565afb642fcdf18b87ebb2dae4e9e365c434be9463c1a5d1a4c4ab17b95a87b89a7f7e3b08
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()