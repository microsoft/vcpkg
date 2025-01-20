include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 8933841f0a7f8737f61404cf0a64acf6b079c8a5
        HEAD_REF main
        SHA512 1a067053d18217f204d686476ad3947a90e7b46c90f21a6bb8346da8aea14021f92dd3d80a5cb57d0990655148860f15fb2f1c20f10d48a4c711a920ab3c8f19
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
