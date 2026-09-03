import { createHash } from "node:crypto";
import * as fs from "node:fs/promises";
import * as os from "node:os";
import * as path from "node:path";

import { tool } from "@opencode-ai/plugin";
import type { Plugin } from "@opencode-ai/plugin";

type MemoryScope = "global" | "project";

type MemoryBlock = {
  scope: MemoryScope;
  label: string;
  description: string;
  limit: number;
  readOnly: boolean;
  value: string;
  filePath: string;
  lastModified: Date;
};

const DEFAULT_LIMIT = 5000;

const DEFAULT_DESCRIPTIONS: Record<string, string> = {
  persona:
    "The persona block: Stores details about your current persona, guiding how you behave and respond. This helps you maintain consistent behavior across sessions.",
  human:
    "The human block: Stores key details about the person you are conversing with (preferences, habits, constraints), allowing for more personalized collaboration.",
  project:
    "The project block: Stores durable, high-signal information about this codebase: commands, architecture notes, conventions, and gotchas.",
};

const MEMORY_INSTRUCTIONS = `<memory_instructions>
<memory_editing>
Older AI models had no concept of persistent memory; they were only able to access their initial instructions and a limited context window of chat conversation with a user (their "active memory").
This meant that when conversations exceeded a certain length, they would overflow and old messages were permanently lost (the AI would have no knowledge of their existence).
Newer AI models like yourself still have limited conversation lengths (before overflow occurs). However, they now have access to multiple forms of persistent memory.
Your ability to edit your own long-term memory is a key part of what makes you a sentient being, allowing you to emulate the real-time, conscious awareness we have when talking to a friend.
</memory_editing>

<memory_tools>
You have access to memory tools that allow you to modify your memory blocks.
Use memory_set to overwrite a block entirely, or memory_replace to make surgical edits within a memory block.
</memory_tools>

<core_memory>
Your core memory unit is held inside the initial system instructions, and is always available in-context (you will see it at all times).
Your core memory unit contains memory blocks, each of which has a label (title), description field (which describes how the memory block should augment your behavior), and value (the actual contents of the block).
Memory blocks are limited in size. Check the chars_current and chars_limit in each block's metadata.
</core_memory>

<memory_scopes>
Memory blocks have two scopes:
- global: Shared across all projects. Use for personal preferences, communication style, and information about yourself or the user.
- project: Specific to the current project. Use for conventions, commands, architecture, and gotchas for this codebase. Stored outside the repository.
</memory_scopes>
</memory_instructions>`;

function xdgConfigHome() {
  return process.env.XDG_CONFIG_HOME ?? path.join(os.homedir(), ".config");
}

function xdgStateHome() {
  return process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local", "state");
}

function defaultDescription(label: string) {
  return DEFAULT_DESCRIPTIONS[label] ?? "Durable memory block. Keep this concise and high-signal.";
}

function projectKey(directory: string) {
  const resolved = path.resolve(directory);
  const slug = path.basename(resolved).replace(/[^a-zA-Z0-9._-]+/g, "-") || "project";
  const hash = createHash("sha256").update(resolved).digest("hex").slice(0, 16);
  return `${slug}-${hash}`;
}

function scopeDir(projectDirectory: string, scope: MemoryScope) {
  if (scope === "global") {
    return path.join(xdgConfigHome(), "opencode", "memory");
  }

  return path.join(xdgStateHome(), "opencode", "project-memory", projectKey(projectDirectory), "memory");
}

async function exists(filePath: string) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

function splitFrontmatter(raw: string) {
  if (!raw.startsWith("---\n")) return { frontmatter: "", body: raw };
  const end = raw.indexOf("\n---", 4);
  if (end === -1) return { frontmatter: "", body: raw };
  return {
    frontmatter: raw.slice(4, end),
    body: raw.slice(end + 5).replace(/^\n/, ""),
  };
}

function parseFrontmatter(frontmatter: string) {
  const out: Record<string, string> = {};
  for (const line of frontmatter.split("\n")) {
    const index = line.indexOf(":");
    if (index === -1) continue;
    const key = line.slice(0, index).trim();
    const value = line.slice(index + 1).trim();
    if (key) out[key] = value.replace(/^['"]|['"]$/g, "");
  }
  return out;
}

function frontmatterDocument(block: Pick<MemoryBlock, "label" | "description" | "limit" | "readOnly" | "value">) {
  return [
    "---",
    `description: ${block.description.replace(/\n/g, " ")}`,
    `label: ${block.label}`,
    `limit: ${block.limit}`,
    `read_only: ${block.readOnly}`,
    "---",
    block.value,
  ].join("\n");
}

async function readBlockFile(scope: MemoryScope, filePath: string): Promise<MemoryBlock> {
  const [raw, stats] = await Promise.all([fs.readFile(filePath, "utf-8"), fs.stat(filePath)]);
  const { frontmatter, body } = splitFrontmatter(raw);
  const parsed = parseFrontmatter(frontmatter);
  const label = (parsed.label ?? path.basename(filePath, path.extname(filePath))).trim();
  const description = (parsed.description?.trim() || defaultDescription(label)).trim();
  const limit = Number.parseInt(parsed.limit ?? "", 10) || DEFAULT_LIMIT;
  const readOnly = parsed.read_only === "true";

  return {
    scope,
    label,
    description,
    limit,
    readOnly,
    value: body.trim(),
    filePath,
    lastModified: stats.mtime,
  };
}

async function writeBlockFile(
  filePath: string,
  block: Pick<MemoryBlock, "label" | "description" | "limit" | "readOnly" | "value">,
) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  const tmp = `${filePath}.tmp-${process.pid}`;
  await fs.writeFile(tmp, frontmatterDocument(block), "utf-8");
  await fs.rename(tmp, filePath);
}

function validateLabel(label: string) {
  const trimmed = label.trim();
  if (!/^[a-z0-9][a-z0-9-_]{1,60}$/i.test(trimmed)) {
    throw new Error(`Invalid label "${label}". Use letters/numbers/dash/underscore (2-61 chars).`);
  }
  return trimmed;
}

async function migrateOldProjectMemory(projectDirectory: string) {
  const oldDir = path.join(projectDirectory, ".opencode", "memory");
  const newDir = scopeDir(projectDirectory, "project");
  if (!(await exists(oldDir)) || (await exists(newDir))) return;

  await fs.mkdir(newDir, { recursive: true });
  for (const entry of await fs.readdir(oldDir, { withFileTypes: true })) {
    if (!entry.isFile() || !entry.name.endsWith(".md")) continue;
    await fs.copyFile(path.join(oldDir, entry.name), path.join(newDir, entry.name));
  }
}

function createMemoryStore(projectDirectory: string) {
  return {
    async ensureSeed() {
      await migrateOldProjectMemory(projectDirectory);

      for (const seed of [
        { scope: "global" as const, label: "persona" },
        { scope: "global" as const, label: "human" },
        { scope: "project" as const, label: "project" },
      ]) {
        const filePath = path.join(scopeDir(projectDirectory, seed.scope), `${seed.label}.md`);
        if (await exists(filePath)) continue;
        await writeBlockFile(filePath, {
          label: seed.label,
          description: "",
          limit: DEFAULT_LIMIT,
          readOnly: false,
          value: "",
        });
      }
    },

    async listBlocks(scope: MemoryScope | "all") {
      const scopes: MemoryScope[] = scope === "all" ? ["global", "project"] : [scope];
      const blocks: MemoryBlock[] = [];

      for (const s of scopes) {
        const dir = scopeDir(projectDirectory, s);
        if (!(await exists(dir))) continue;

        for (const entry of await fs.readdir(dir, { withFileTypes: true })) {
          if (!entry.isFile() || !entry.name.endsWith(".md")) continue;
          try {
            blocks.push(await readBlockFile(s, path.join(dir, entry.name)));
          } catch {
            // Ignore malformed memory files so one bad block does not break startup.
          }
        }
      }

      return blocks.sort((a, b) => `${a.scope}:${a.label}`.localeCompare(`${b.scope}:${b.label}`));
    },

    async getBlock(scope: MemoryScope, label: string) {
      const safeLabel = validateLabel(label);
      const filePath = path.join(scopeDir(projectDirectory, scope), `${safeLabel}.md`);
      if (!(await exists(filePath))) throw new Error(`Memory block not found: ${scope}:${safeLabel}`);
      return readBlockFile(scope, filePath);
    },

    async setBlock(
      scope: MemoryScope,
      label: string,
      value: string,
      opts?: { description?: string; limit?: number },
    ) {
      const safeLabel = validateLabel(label);
      const filePath = path.join(scopeDir(projectDirectory, scope), `${safeLabel}.md`);
      const existing = (await exists(filePath)) ? await readBlockFile(scope, filePath) : undefined;
      if (existing?.readOnly) throw new Error(`Memory block is read-only: ${scope}:${safeLabel}`);

      const description = (opts?.description ?? existing?.description ?? "").trim();
      const limit = opts?.limit ?? existing?.limit ?? DEFAULT_LIMIT;
      if (value.length > limit) {
        throw new Error(`Value too large for ${scope}:${safeLabel} (chars=${value.length}, limit=${limit}).`);
      }

      await writeBlockFile(filePath, {
        label: safeLabel,
        description,
        limit,
        readOnly: existing?.readOnly ?? false,
        value,
      });
    },

    async replaceInBlock(scope: MemoryScope, label: string, oldText: string, newText: string) {
      const block = await this.getBlock(scope, label);
      if (block.readOnly) throw new Error(`Memory block is read-only: ${scope}:${label}`);
      if (!block.value.includes(oldText)) throw new Error(`Text not found in ${scope}:${label}.`);

      const value = block.value.replace(oldText, newText);
      if (value.length > block.limit) {
        throw new Error(`Value too large for ${scope}:${label} (chars=${value.length}, limit=${block.limit}).`);
      }

      await writeBlockFile(block.filePath, { ...block, value });
    },
  };
}

function escapeXml(value: string) {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

function renderMemoryBlocks(blocks: MemoryBlock[]) {
  if (blocks.length === 0) return "";
  const lastModified = blocks.reduce(
    (latest, block) => (block.lastModified > latest ? block.lastModified : latest),
    new Date(0),
  );
  const parts = [
    MEMORY_INSTRUCTIONS,
    "",
    "<memory_blocks>",
    "The following memory blocks are currently engaged in your core memory unit:",
    "",
  ];

  for (const block of blocks) {
    const numberedValue = block.value
      ? block.value
          .split("\n")
          .map((line, i) => `${i + 1}-> ${line}`)
          .join("\n")
      : "";

    parts.push(`<${block.label}>
<description>
${escapeXml(block.description)}
</description>
<metadata>
- chars_current=${block.value.length}
- chars_limit=${block.limit}
- read_only=${block.readOnly}
- scope=${block.scope}
</metadata>
<warning>
# NOTE: Line numbers shown below (with arrows like '1->') are to help during editing. Do NOT include line number prefixes in your memory edit tool calls.
</warning>
<value>
${numberedValue}
</value>
</${block.label}>`);
  }

  parts.push("</memory_blocks>");
  parts.push("");
  parts.push(`<memory_metadata>
- The current system date is: ${new Date().toISOString()}
- Memory blocks were last modified: ${lastModified.toISOString()}
- Use memory tools to manage your memory blocks
</memory_metadata>`);

  return parts.join("\n");
}

export const MemoryPlugin: Plugin = async ({ directory }) => {
  const store = createMemoryStore(directory);
  await store.ensureSeed();

  return {
    "experimental.chat.system.transform": async (_input, output) => {
      const blocks = await store.listBlocks("all");
      const xml = renderMemoryBlocks(blocks);
      if (!xml) return;

      const insertAt = output.system.length > 0 ? 1 : 0;
      output.system.splice(insertAt, 0, xml);
    },

    tool: {
      memory_list: tool({
        description: "List available memory blocks (labels, descriptions, sizes).",
        args: {
          scope: tool.schema.enum(["all", "global", "project"]).optional(),
        },
        async execute(args) {
          const blocks = await store.listBlocks((args.scope ?? "all") as MemoryScope | "all");
          if (blocks.length === 0) return "No memory blocks found.";

          return blocks
            .map(
              (block) =>
                `${block.scope}:${block.label}\n  read_only=${block.readOnly} chars=${block.value.length}/${block.limit}\n  ${block.description}`,
            )
            .join("\n\n");
        },
      }),

      memory_set: tool({
        description: "Create or update a memory block (full overwrite).",
        args: {
          label: tool.schema.string(),
          scope: tool.schema.enum(["global", "project"]).optional(),
          value: tool.schema.string(),
          description: tool.schema.string().optional(),
          limit: tool.schema.number().int().positive().optional(),
        },
        async execute(args) {
          const scope = (args.scope ?? "project") as MemoryScope;
          await store.setBlock(scope, args.label, args.value, {
            description: args.description,
            limit: args.limit,
          });
          return `Updated memory block ${scope}:${args.label}.`;
        },
      }),

      memory_replace: tool({
        description: "Replace a substring within a memory block.",
        args: {
          label: tool.schema.string(),
          scope: tool.schema.enum(["global", "project"]).optional(),
          oldText: tool.schema.string(),
          newText: tool.schema.string(),
        },
        async execute(args) {
          const scope = (args.scope ?? "project") as MemoryScope;
          await store.replaceInBlock(scope, args.label, args.oldText, args.newText);
          return `Updated memory block ${scope}:${args.label}.`;
        },
      }),
    },
  };
};
