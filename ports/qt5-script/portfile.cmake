include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(
    PATCHES
        msvc-copysign.patch
        # In the 64-bit representation, TagTypeNumber is 0xffff000000000000.
        # Testing that all upper 16 bits are set is equivalent to unsigned >=
        # TagTypeNumber; both operands must be unsigned. This equivalence does
        # not hold for arbitrary masks. Avoids an MSVC 19.52 optimizer ICE.
        msvc-jsvalue-tag.patch
)