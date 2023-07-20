function(acquire_pciids out_var)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO pciutils/pciids
        REF 4e3f51b4b7ba7ffd3cca463d6a19daf0f4270252
        SHA512 952b56affffdf9ecf78f6125cf4216bd01d85c55e49ec4b2dfb3a77bae2258dec6b4e2d28824d6408f072667480ef7e5f7279fd69bae65c071b7b3816fe9f504
    )
    set(${out_var} "${SOURCE_PATH}/pci.ids" PARENT_SCOPE)
endfunction()
