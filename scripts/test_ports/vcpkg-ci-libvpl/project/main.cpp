#include <vpl/mfx.h>

int main() {
    mfxLoader loader = MFXLoad();
    if (loader == nullptr) {
        return 1;
    }
    MFXUnload(loader);
    return 0;
}
