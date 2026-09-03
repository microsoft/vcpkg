#pragma once
#include <gio/gio.h>
#include <glib-object.h>
#include <glib.h>
#include <string.h>

#ifdef __cplusplus
// Magic trick to allow implicit void* conversion in C++
struct PxCastHelper
{
    void *p;
    PxCastHelper(void *ptr) : p(ptr)
    {
    }
    template <typename T> operator T *() const
    {
        return (T *)p;
    }
    template <typename T> operator const T *() const
    {
        return (const T *)p;
    }
    operator bool() const
    {
        return p != nullptr;
    }
};

// RAII cleanup helper for MSVC (C++ mode)
template <typename T, void (*f)(void *)> struct PxCleanup
{
    T *p;
    PxCleanup(T *ptr) : p(ptr)
    {
    }
    ~PxCleanup()
    {
        if (p && *p)
            f((void *)p);
    }
};

inline void px_g_free_cleanup(void *p)
{
    g_free(*(void **)p);
}

// GLib macro overrides to use PxCastHelper where needed
#undef g_object_new
#define g_object_new(...) PxCastHelper(g_object_new(__VA_ARGS__))
#undef g_memdup2
#define g_memdup2(...) PxCastHelper(g_memdup2(__VA_ARGS__))
#undef g_malloc
#define g_malloc(...) PxCastHelper(g_malloc(__VA_ARGS__))
#undef g_malloc0
#define g_malloc0(...) PxCastHelper(g_malloc0(__VA_ARGS__))
#undef g_realloc
#define g_realloc(...) PxCastHelper(g_realloc(__VA_ARGS__))
#undef g_steal_pointer
#define g_steal_pointer(p) (PxCastHelper(g_steal_pointer(p)))
#undef g_hash_table_lookup
#define g_hash_table_lookup(...) PxCastHelper(g_hash_table_lookup(__VA_ARGS__))
#undef g_list_append
#define g_list_append(...) PxCastHelper(g_list_append(__VA_ARGS__))
#undef g_list_insert_sorted
#define g_list_insert_sorted(...) PxCastHelper(g_list_insert_sorted(__VA_ARGS__))

// Enums and other fixes
#define g_param_spec_string(a, b, c, d, e) (g_param_spec_string)(a, b, c, d, (GParamFlags)(e))
#define g_param_spec_boolean(a, b, c, d, e) (g_param_spec_boolean)(a, b, c, d, (GParamFlags)(e))
#define g_signal_connect_object(a, b, c, d, e) (g_signal_connect_object)(a, b, c, d, (GConnectFlags)(e))

// Missing cleanup functions for some types
inline void glib_autoptr_cleanup_PxConfig(void *p)
{
    if (*(void **)p)
        g_object_unref(*(void **)p);
}
inline void glib_autoptr_cleanup_GStrvBuilder(void *p)
{
    if (*(void **)p)
        g_strv_builder_unref((GStrvBuilder *)*(void **)p);
}
inline void glib_autoptr_cleanup_GUri(void *p)
{
    if (*(void **)p)
        g_uri_unref((GUri *)*(void **)p);
}
inline void glib_auto_cleanup_GStrv(void *p)
{
    if (*(void **)p)
        g_strfreev(*(char ***)p);
}
inline void glib_autoptr_cleanup_GError(void *p)
{
    if (*(void **)p)
        g_error_free((GError *)*(void **)p);
}
inline void glib_autoptr_cleanup_GHashTable(void *p)
{
    if (*(void **)p)
        g_hash_table_unref((GHashTable *)*(void **)p);
}
inline void glib_autoptr_cleanup_GVariant(void *p)
{
    if (*(void **)p)
        g_variant_unref((GVariant *)*(void **)p);
}
inline void glib_autoptr_cleanup_GInetAddress(void *p)
{
    if (*(void **)p)
        g_object_unref(*(void **)p);
}

#endif
