#!/usr/bin/env node
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import AdmZip from "adm-zip";
import { execSync } from "child_process";

const keyword = "/include/";

function writeOutputLines(outDir: string, dbLines: string[], headerLines: string[]) {
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, "VCPKGDatabase.txt"), dbLines.join("\n") + (dbLines.length ? "\n" : ""));
  fs.writeFileSync(path.join(outDir, "VCPKGHeadersDatabase.txt"), headerLines.join("\n") + (headerLines.length ? "\n" : ""));
}

function listZipFiles(buffer: Buffer, pkgName: string, dbLines: string[], headerLines: string[]) {
  const zip = new AdmZip(buffer);
  const entries = zip.getEntries();
  for (const e of entries) {
    if (e.isDirectory) continue;
    const entryName = "/" + e.entryName.replace(/\\/g, "/");
    if (entryName === "/BUILD_INFO" || entryName === "/CONTROL") continue;
    dbLines.push(`${pkgName}:${entryName}`);
    if (entryName.startsWith(keyword)) {
      headerLines.push(`${pkgName}:${entryName.substring(keyword.length)}`);
    }
  }
}

function downloadUrlToBuffer(url: string): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode && res.statusCode >= 400) {
        reject(new Error(`HTTP ${res.statusCode} while fetching ${url}`));
        return;
      }
      const chunks: Buffer[] = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => resolve(Buffer.concat(chunks)));
    }).on("error", reject);
  });
}

function usage() {
  console.error("Usage: file_script_from_cache.ts --pr-hashes <pr-hashes.json> --blob-base-url <blob-base-url> [--target-branch <branch>] [--out-dir <path>]");
  console.error("blob-base-url should include SAS token (e.g. https://<account>.blob.core.windows.net/<container>/?<sas>)");
}

function parseArgs(argv: string[]) {
  // supports: --pr-hashes <path> --blob-base-url <url> [--target-branch <branch>] [--out-dir <path>]
  // legacy: positional: <pr-hashes> <blob-base-url> [target-branch]
  let prHashesPath: string | undefined;
  let blobBaseUrl: string | undefined;
  let targetBranch = "master";
  let outDir = "scripts/list_files";
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--pr-hashes") {
      i++;
      prHashesPath = argv[i];
    } else if (a === "--blob-base-url") {
      i++;
      blobBaseUrl = argv[i];
    } else if (a === "--target-branch") {
      i++;
      targetBranch = argv[i];
    } else if (a === "--out-dir") {
      i++;
      outDir = argv[i];
    } else if (a.startsWith("--")) {
      console.error(`Unknown argument: ${a}`);
      usage();
      process.exit(2);
    } else if (!prHashesPath) {
      prHashesPath = a;
    } else if (!blobBaseUrl) {
      blobBaseUrl = a.replace(/[\/\\]+$/g, "");
    } else if (targetBranch === "master") {
      targetBranch = a;
    } else {
      console.error(`Unexpected positional argument: ${a}`);
      usage();
      process.exit(2);
    }
  }
  if (!prHashesPath || !blobBaseUrl) {
    usage();
    process.exit(2);
  }
  return { prHashesPath, blobBaseUrl, targetBranch, outDir };
}

async function main() {
  const { prHashesPath, blobBaseUrl, targetBranch, outDir } = parseArgs(process.argv.slice(2));

  const prHashes = JSON.parse(fs.readFileSync(prHashesPath, "utf8")) as Array<{ name: string; triplet: string; state: string; abi: string }>;
  // Expect vcpkg-tool produced format: array of objects
  // [ { "name": "zlib", "triplet": "x64-windows", "state": "pass", "abi": "zlib:x64-windows:<sha>" }, ... ]
  if (!Array.isArray(prHashes)) {
    console.error(
      `Invalid pr-hashes.json format: expected a top-level JSON array (vcpkg-tool output).`
    );
    process.exit(2);
  }

  const dbLines: string[] = [];
  const headerLines: string[] = [];

  // Determine list of ports to process from git-diff (only folders under ports/ that changed)
  let changedPorts: string[] = [];
  try {
    const mergebase = execSync(`git merge-base ${targetBranch} HEAD`, { encoding: "utf8" }).trim();
    // Find repository root by locating .vcpkg-root in or above cwd
    function findRepoRoot(): string {
      let dir = process.cwd();
      while (true) {
        if (fs.existsSync(path.join(dir, ".vcpkg-root"))) return dir;
        const parent = path.dirname(dir);
        if (parent === dir) break;
        dir = parent;
      }
      throw new Error("Could not find .vcpkg-root in or above current working directory");
    }

    const repoRoot = findRepoRoot();
    const diffOut = execSync(`git diff --name-only ${mergebase}...HEAD -- ports/`, { encoding: "utf8", cwd: repoRoot });
    const files = diffOut.split(/\r?\n/).filter((l) => l.length > 0);
    const set = new Set<string>();
    for (const f of files) {
      const m = f.match(/^ports\/([^\/]+)/);
      if (m) set.add(m[1]);
    }
    changedPorts = Array.from(set);
    if (changedPorts.length === 0) {
      console.log(`git diff found no changed ports under ports/ for range ${mergebase}...HEAD; exiting.`);
      writeOutputLines(outDir, dbLines, headerLines);
      return;
    }
  } catch (e) {
    console.error(`git diff failed (${e}); this is fatal in PR cache mode.`);
    process.exit(2);
  }

  for (const port of changedPorts) {
    for (const item of prHashes) {
      if (item.name !== port) continue;
      // Validate sha format
      const sha1Regex = /^[a-f0-9]{64}$/;
      if (!sha1Regex.test(item.abi)) {
        throw new Error(`Invalid SHA format in pr-hashes.json for port ${port}: ${item.abi}`);
      }
      const abi = item.abi;
      // blob named <sha>.zip
      // Ensure we append the ABI path before the SAS query string, i.e.:
      // https://.../<container>/<sha>.zip?<sas>
      let blobUrl: string;
      try {
        const u = new URL(blobBaseUrl);
        const sas = u.search; // includes leading '?' or empty
        // build base path without query and without trailing slash
        const baseNoQuery = `${u.origin}${u.pathname.replace(/[\/\\]+$/g, "")}`;
        blobUrl = sas ? `${baseNoQuery}/${abi}.zip${sas}` : `${baseNoQuery}/${abi}.zip`;
      } catch (e) {
        console.error(`Invalid blob base URL provided: ${blobBaseUrl} -- ${e}`);
        process.exit(2);
      }
      console.log(`Downloading ${blobUrl} for port ${port}...`);
      try {
        const buf = await downloadUrlToBuffer(blobUrl);
        listZipFiles(buf, `${port}:${item.triplet}`, dbLines, headerLines);
      } catch (err) {
        console.warn(`Failed to download or process blob for ${port}: ${err}`);
      }
    }
  }

  writeOutputLines(outDir, dbLines, headerLines);
  console.log(`Wrote ${path.join(outDir, "VCPKGDatabase.txt")} and ${path.join(outDir, "VCPKGHeadersDatabase.txt")}`);
}

await main().catch((e) => {
  console.error("Error in script:", e);
  process.exit(1);
});
