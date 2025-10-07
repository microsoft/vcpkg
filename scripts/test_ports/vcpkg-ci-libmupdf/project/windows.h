/* No-op polyfill to enable compilation for non-windows targets. */

typedef void* HANDLE;

#define INFINITE 0

static HANDLE CreateSemaphore(void*, long, long, void*)
{
    return NULL;
}

static int ReleaseSemaphore(HANDLE, long, void*)
{
    return 0;
}

static int WaitForSingleObject(HANDLE, int)
{
    return 0;
}

static void CloseHandle(HANDLE)
{}
