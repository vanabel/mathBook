import fs from "node:fs";

const sourcePath = "TERMINOLOGY.md";
const outputPath = "chapters/terminology-glossary.tex";
const source = fs.readFileSync(sourcePath, "utf8");

// Parse Markdown table rows. Both 3-column rows
// (| 英文 | 推荐译名 | 说明 |) and 4-column rows with an extra
// "规范名词" column are accepted. Cells must not contain a literal "|".
const rows = [];
for (const line of source.split(/\r?\n/)) {
  const trimmed = line.trim();
  if (!trimmed.startsWith("|") || !trimmed.endsWith("|")) {
    continue;
  }

  const cells = trimmed
    .replace(/^\|/, "")
    .replace(/\|\s*$/, "")
    .split("|")
    .map((cell) => cell.trim());

  if (cells.length < 3 || cells[0] === "英文" || /^-+$/.test(cells[0])) {
    continue;
  }

  const [english, chinese, note, standard = ""] = cells;
  rows.push({ english, chinese, note, standard });
}

if (rows.length === 0) {
  throw new Error(`No terminology rows found in ${sourcePath}`);
}

const entries = rows.map(({ english, chinese, note, standard }, index) => {
  const label = `term-${String(index + 1).padStart(3, "0")}`;
  const noteText = standard ? `${note}；规范名词: ${standard}` : note;
  return [
    `\\newglossaryentry{${label}}{`,
    "  type={terms},",
    `  name={${english}},`,
    `  sort={${english.toLocaleLowerCase("en")}},`,
    `  description={\\terminologydescription{${chinese}}{${noteText}}}`,
    "}",
  ].join("\n");
});

const output = [
  "% This file is generated from TERMINOLOGY.md.",
  "% Run `make terminology` after editing the Markdown source.",
  "",
  ...entries.flatMap((entry) => [entry, ""]),
].join("\n");

fs.writeFileSync(outputPath, output, "utf8");
console.log(`Generated ${outputPath} with ${rows.length} entries.`);
