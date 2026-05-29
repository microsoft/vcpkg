#include <stdio.h>
#include <podofo/podofo.h>

int main()
{
    PoDoFo::PdfMemDocument document;
    auto font = document.GetFonts().SearchFont("Arial");
    if (document.GetPages().GetCount() > 0)
    {
        auto& page = document.GetPages().GetPageAt(0);
        auto& signature = page.CreateField<PoDoFo::PdfSignature>("Signature2", PoDoFo::Rect());
        char x509certbuffer[256], pkeybuffer[256];
        PoDoFo::PdfSignerCms signer(x509certbuffer, pkeybuffer);
    }
    return 0;
}
