include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openscenegraph/osgQt
    REF 6d324db8a56feb7d1976e9fb3f1de9bf7d255646
    SHA512 6c6c0220de1b2314bc0e8ba149ef794229e0858914014dab91d577965acb19925dd64b8ee08add7b77f9353951ccf18f8e80b648509f894f3c2aaa08204b7625
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

#Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle License
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/osg-qt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/osg-qt/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/osg-qt/copyright)