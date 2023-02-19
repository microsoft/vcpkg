// Based on cmake-js
// https://github.com/cmake-js/cmake-js/blob/e2452ee226490bc666d286ab0860aeb35fbbb035/lib/cMake.js#L293

const headers = require('.');

// Compile a Set of all the symbols that could be exported
const allSymbols = new Set()
for (const ver of Object.values(headers.symbols)) {
    for (const sym of ver.node_api_symbols) {
        allSymbols.add(sym)
    }
    for (const sym of ver.js_native_api_symbols) {
        allSymbols.add(sym)
    }
}

// Write a 'def' file for NODE.EXE
const allSymbolsArr = Array.from(allSymbols)
await fs.writeFile("./node.def", 'NAME NODE.EXE\nEXPORTS\n' + allSymbolsArr.join('\n'))
