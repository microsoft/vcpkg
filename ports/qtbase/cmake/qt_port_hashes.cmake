set(QT_VERSION 6.0.0-beta5)
set(QT_GIT_REF v${QT_VERSION})
set(QT_UPDATE_VERSION FALSE)

set(QT_PORTS qtbase 
             qttools 
             qtdeclarative
             qtsvg
             qt5compat
             qtshadertools
             qtquicktimeline
             qtquick3d
             qttranslations
             qtwayland
             qtdoc)

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_REF ${QT_GIT_REF})
endforeach()

set(qtbase_HASH             ea97ca813757f31a5a1eb2d6bd1f1726bb6d0306fc7a10d00974341cc99aaf8b04edd1a77277371efe11f8b00fa0123145fce4a49a7ac4901ef835917803be6b)
set(qttools_HASH            f900186d0fa60a8de4324e7a7a6d9eae82be0edfc4c1c342a79fe058d27980b793402b085deb5536b9e7e110e08b51e838b0cb9ea19d291d503e035145a21542)
set(qtdeclarative_HASH      1e7ce42b69c1d5ef7b0755b70855bd904059d7613e7c5eb1a9555b757c5a1fa644a7210595b95c6d9e360de340d1cfd307e2e1882b0693406b505abce25c55e9)
set(qtsvg_HASH              5b15823db32839e89db4ffd953075ae9709c94f2af211d19ea04801616225e4a06dffc161e556e0b49da341544a12b42c7e1de4dc8241cd7c2a68f8703e5dd33)
set(qt5compat_HASH          447bc1ad76b7bce4e9da450c8441902147498ffb07817bd4ce727e185ac5b73d8cc8432e75d840fc80faa0b5bf93d9c34f9b3d2e3577ec09459d3c5a4d3d7ada)
set(qtshadertools_HASH      205ee8d27598dd7796d4c613a0619f2c810adf7ca95ec4ad2a00a6e50527a87852eb01138ea3d96c8491e4fb9d08e5a980c33e3f141ff4653c7673e44fca579d)
set(qtquicktimeline_HASH    a5098144aaf8ad2f12f03da4d76de6ce3a99096cd202d35e5a7c0b25e439c09c19abe1f6041a6a0d32bc949f78f3c6a35f460f1c3ab0ca8ec3a60d9953fc8126)
set(qtquick3d_HASH          a137767db8a5a2f41dada78ee1e0c53f600975070eddbdab0ccc4761af4ea6e99d4d720381151090983e307b200ddbd46fe1214a9ad612e2652bea44682236ad)
set(qttranslations_HASH     25fad1a10d886e807c3a77f39f72ddc02d5fac1be42fbbce710e8b9ec9e19ec069fa0dbe6daf7aa542b6754f6bf74238ef0ea6019a16102e0a7ceb002d35baf4)
set(qtwayland_HASH          61652e2962676362b09bb001f3aadacb4c25cd882f8d2644a7c28497c3f7d383538958c599bd3f2d1526d5f0967be606a67b715a71a58acb9a17ea8d041ed6b5)
set(qtdoc_HASH              e6495b75ec70a1afb95b43277865588324db5f75ceb8114ada93f8f121b08d9deb1b964e302e86c4b6fb9ef146d157e33dffab51fd4b6ade4dffee87980ef963)


#TODO: qtquickcontrols2 
#      (qtimageformats ? no tag yet)
#      (qtgamepad ?)
#      (qtcharts ?)

# List of added an removed modules https://doc-snapshots.qt.io/qt6-dev/whatsnew60.html#changes-to-supported-modules

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-string\": [^\n]+\n" "\"version-string\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()