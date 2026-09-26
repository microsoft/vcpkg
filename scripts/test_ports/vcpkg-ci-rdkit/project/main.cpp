#include <GraphMol/MolDraw2D/MolDraw2DCairo.h>
#include <GraphMol/SmilesParse/SmilesParse.h>
#include <GraphMol/SmilesParse/SmilesWrite.h>

#include <cstddef>
#include <iostream>
#include <memory>
#include <string>

int main() {
  std::unique_ptr<RDKit::ROMol> molecule{RDKit::SmilesToMol("CCO")};
  if (!molecule) {
    return 1;
  }

  RDKit::MolDraw2DCairo drawer(250, 200);
  drawer.drawMolecule(*molecule);
  drawer.finishDrawing();
  const std::string png = drawer.getDrawingText();

  constexpr unsigned char signature[] = {0x89, 0x50, 0x4e, 0x47,
                                         0x0d, 0x0a, 0x1a, 0x0a};
  if (png.size() < sizeof(signature)) {
    return 2;
  }
  for (std::size_t index = 0; index < sizeof(signature); ++index) {
    if (static_cast<unsigned char>(png[index]) != signature[index]) {
      return 3;
    }
  }

  const std::string smiles = RDKit::MolToSmiles(*molecule);
  if (smiles != "CCO") {
    return 4;
  }

  std::cout << smiles << " " << png.size() << '\n';
  return 0;
}
