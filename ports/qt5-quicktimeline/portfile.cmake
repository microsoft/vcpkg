set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(QT_HASH_qt5-quicktimeline 0d27b672a76fdb6ba531bc823792bbcda2f286cebf9b64332651544344c1d78c9d397d40b3ccd426cea4dea6ea0971cc142ce0258a1f5a92a2239b39aef79054)

#vcpkg_download_distfile(
#    ARCHIVE
#    URLS "https://mirrors.sjtug.sjtu.edu.cn/qt/archive/qt/5.15/5.15.16/submodules/qtquicktimeline-everywhere-opensource-src-5.15.16.tar.xz"
#    FILENAME "qtquicktimeline-everywhere-opensource-src-5.15.16.tar.xz"
#    SHA512 0    
#)

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation()