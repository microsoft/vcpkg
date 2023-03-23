if(MSVC)
    # This port's tools use C++20, but Qt6 (via OpenCV4) uses C++17.
    # Assuming that no coroutines are passed between the two.
    add_definitions(-D_ALLOW_COROUTINE_ABI_MISMATCH)
endif()
