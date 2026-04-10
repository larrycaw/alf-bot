# =============================================================
# Loot Ledger — Apply All Phases (Windows PowerShell)
# Run from your project root: .\scripts\apply-all.ps1
# =============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Loot Ledger - Applying All Phases" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── Check we're in the right folder ──────────────────────────
if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: Run this from your project root (where package.json is)" -ForegroundColor Red
    exit 1
}

# ── Phase 0: Install new dependencies ────────────────────────
Write-Host "[Phase 0] Installing dependencies..." -ForegroundColor Yellow
npm install @upstash/ratelimit @upstash/redis
npm install -D @cloudflare/next-on-pages wrangler
Write-Host "[Phase 0] Dependencies installed." -ForegroundColor Green
Write-Host ""

# ── Phase 0: Add scripts to package.json ─────────────────────
Write-Host "[Phase 0] Adding Cloudflare scripts to package.json..." -ForegroundColor Yellow
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts['pages:build'] = 'npx @cloudflare/next-on-pages@1';
pkg.scripts['pages:dev'] = 'npx wrangler pages dev .vercel/output/static';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('Done.');
"
Write-Host "[Phase 0] Scripts added." -ForegroundColor Green
Write-Host ""

# ── Phase 0: Delete old feature folders ──────────────────────
Write-Host "[Phase 0] Removing old boards/cards folders..." -ForegroundColor Yellow
if (Test-Path "src\features\boards") { Remove-Item -Recurse -Force "src\features\boards" }
if (Test-Path "src\features\cards") { Remove-Item -Recurse -Force "src\features\cards" }
Write-Host "[Phase 0] Old folders removed." -ForegroundColor Green
Write-Host ""

# ── Phase 0: Create new files ────────────────────────────────
Write-Host "[Phase 0] Creating rate-limit, env types, deploy config..." -ForegroundColor Yellow

# rate-limit.ts
$rateLimitDir = "src\lib"
if (-not (Test-Path $rateLimitDir)) { New-Item -ItemType Directory -Path $rateLimitDir -Force | Out-Null }
@'
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

export const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "10 s"),
  analytics: true,
  prefix: "loot-ledger",
});

export const authRatelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, "60 s"),
  analytics: true,
  prefix: "loot-ledger:auth",
});
'@ | Set-Content -Path "src\lib\rate-limit.ts" -Encoding UTF8

# env.d.ts
@'
interface CloudflareEnv {
  NEXT_PUBLIC_SUPABASE_URL: string;
  NEXT_PUBLIC_SUPABASE_ANON_KEY: string;
  NEXT_PUBLIC_APP_URL: string;
}

declare global {
  namespace NodeJS {
    interface ProcessEnv extends CloudflareEnv {}
  }
}

export {};
'@ | Set-Content -Path "src\types\env.d.ts" -Encoding UTF8

# wrangler.toml
@'
name = "loot-ledger"
compatibility_date = "2024-09-23"
compatibility_flags = ["nodejs_compat"]

[vars]
NEXT_PUBLIC_APP_URL = "https://lootledger.dev"
'@ | Set-Content -Path "wrangler.toml" -Encoding UTF8

# deploy.yml
$deployDir = ".github\workflows"
if (-not (Test-Path $deployDir)) { New-Item -ItemType Directory -Path $deployDir -Force | Out-Null }
@'
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: Build & Deploy
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: "npm"

      - run: npm ci

      - name: Build for Cloudflare Pages
        run: npx @cloudflare/next-on-pages@1
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
          NEXT_PUBLIC_APP_URL: https://lootledger.dev

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy .vercel/output/static --project-name=loot-ledger
'@ | Set-Content -Path ".github\workflows\deploy.yml" -Encoding UTF8

Write-Host "[Phase 0] Config files created." -ForegroundColor Green
Write-Host ""

# ── Phase 1: Database types ──────────────────────────────────
Write-Host "[Phase 1] Writing database types..." -ForegroundColor Yellow

@'
export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string | null;
          avatar_url: string | null;
          created_at: string;
        };
        Insert: {
          id: string;
          display_name?: string | null;
          avatar_url?: string | null;
        };
        Update: {
          display_name?: string | null;
          avatar_url?: string | null;
        };
      };
      workspaces: {
        Row: {
          id: string;
          user_id: string;
          name: string;
          icon: string;
          color: string;
          type: WorkspaceType;
          sort_order: number;
          config: Record<string, unknown>;
          archived_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          name: string;
          icon?: string;
          color?: string;
          type?: WorkspaceType;
          sort_order?: number;
          config?: Record<string, unknown>;
          archived_at?: string | null;
        };
        Update: {
          name?: string;
          icon?: string;
          color?: string;
          type?: WorkspaceType;
          sort_order?: number;
          config?: Record<string, unknown>;
          archived_at?: string | null;
        };
      };
      workspace_columns: {
        Row: {
          id: string;
          workspace_id: string;
          name: string;
          type: ColumnType;
          sort_order: number;
          config: ColumnConfig;
          created_at: string;
        };
        Insert: {
          id?: string;
          workspace_id: string;
          name: string;
          type?: ColumnType;
          sort_order?: number;
          config?: ColumnConfig;
        };
        Update: {
          name?: string;
          type?: ColumnType;
          sort_order?: number;
          config?: ColumnConfig;
        };
      };
      workspace_rows: {
        Row: {
          id: string;
          workspace_id: string;
          data: Record<string, unknown>;
          sort_order: number;
          search_text: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          workspace_id: string;
          data?: Record<string, unknown>;
          sort_order?: number;
        };
        Update: {
          data?: Record<string, unknown>;
          sort_order?: number;
        };
      };
      assumptions: {
        Row: {
          id: string;
          workspace_id: string;
          key: string;
          label: string;
          value: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          workspace_id: string;
          key: string;
          label: string;
          value?: number;
        };
        Update: {
          label?: string;
          value?: number;
        };
      };
    };
    Views: Record<string, never>;
    Functions: {
      search_workspace_rows: {
        Args: {
          p_workspace_id: string;
          p_query: string;
          p_limit?: number;
        };
        Returns: Database["public"]["Tables"]["workspace_rows"]["Row"][];
      };
    };
    Enums: Record<string, never>;
  };
};

export type WorkspaceType = "table";

export type ColumnType =
  | "text"
  | "number"
  | "currency"
  | "date"
  | "select"
  | "formula"
  | "auto-id"
  | "notes";

export type ColumnConfig = {
  currencySymbol?: string;
  options?: string[];
  formula?: string;
  autoFill?: "today" | "increment";
  width?: number;
  summary?: "sum" | "avg" | "count" | "none";
};

export type Workspace = Database["public"]["Tables"]["workspaces"]["Row"];
export type WorkspaceInsert = Database["public"]["Tables"]["workspaces"]["Insert"];
export type WorkspaceUpdate = Database["public"]["Tables"]["workspaces"]["Update"];
export type WorkspaceColumn = Database["public"]["Tables"]["workspace_columns"]["Row"];
export type WorkspaceRow = Database["public"]["Tables"]["workspace_rows"]["Row"];
export type Assumption = Database["public"]["Tables"]["assumptions"]["Row"];
'@ | Set-Content -Path "src\types\database.ts" -Encoding UTF8

@'
export type {
  Database,
  Workspace,
  WorkspaceInsert,
  WorkspaceUpdate,
  WorkspaceColumn,
  WorkspaceRow,
  Assumption,
  WorkspaceType,
  ColumnType,
  ColumnConfig,
} from "./database";
'@ | Set-Content -Path "src\types\index.ts" -Encoding UTF8

Write-Host "[Phase 1] Database types written." -ForegroundColor Green
Write-Host ""

# ── Phase 1: Workspaces feature ──────────────────────────────
Write-Host "[Phase 1] Creating workspaces feature..." -ForegroundColor Yellow

$wsDir = "src\features\workspaces"
$wsCompDir = "$wsDir\components"
$wsTestDir = "$wsDir\__tests__"
New-Item -ItemType Directory -Path $wsCompDir -Force | Out-Null
New-Item -ItemType Directory -Path $wsTestDir -Force | Out-Null

# types.ts
@'
export type { Workspace, WorkspaceInsert, WorkspaceUpdate } from "@/types/database";

export type WorkspaceColor =
  | "#6366f1" | "#f59e0b" | "#10b981" | "#ef4444"
  | "#8b5cf6" | "#ec4899" | "#06b6d4" | "#f97316";

export const WORKSPACE_COLORS: { value: WorkspaceColor; label: string }[] = [
  { value: "#6366f1", label: "Indigo" },
  { value: "#f59e0b", label: "Amber" },
  { value: "#10b981", label: "Emerald" },
  { value: "#ef4444", label: "Red" },
  { value: "#8b5cf6", label: "Violet" },
  { value: "#ec4899", label: "Pink" },
  { value: "#06b6d4", label: "Cyan" },
  { value: "#f97316", label: "Orange" },
];

export const WORKSPACE_ICONS = [
  "\u{1F4CA}", "\u{1F4C8}", "\u{1F4B0}", "\u{1F3AE}", "\u{1F4CB}", "\u{1F4DD}", "\u{1F3AF}", "\u{26A1}",
  "\u{1F3C6}", "\u{1F48E}", "\u{1F525}", "\u{1F4E6}", "\u{1F6D2}", "\u{1F3B2}", "\u{1F4FA}", "\u{1F9EA}",
];
'@ | Set-Content -Path "$wsDir\types.ts" -Encoding UTF8

# index.ts (barrel)
@'
export { WorkspaceGrid } from "./components/workspace-grid";
export { WorkspaceCard } from "./components/workspace-card";
export { CreateWorkspaceForm } from "./components/create-workspace-form";
export {
  getWorkspaces,
  createWorkspace,
  updateWorkspace,
  archiveWorkspace,
  deleteWorkspace,
  reorderWorkspaces,
} from "./actions";
export { WORKSPACE_COLORS, WORKSPACE_ICONS } from "./types";
'@ | Set-Content -Path "$wsDir\index.ts" -Encoding UTF8

Write-Host "[Phase 1] Workspaces feature structure created." -ForegroundColor Green
Write-Host ""

# ── Phase 2: Tables feature ─────────────────────────────────
Write-Host "[Phase 2] Creating tables feature..." -ForegroundColor Yellow

$tblDir = "src\features\tables"
$tblCompDir = "$tblDir\components"
$tblActDir = "$tblDir\actions"
$tblTestDir = "$tblDir\__tests__"
New-Item -ItemType Directory -Path $tblCompDir -Force | Out-Null
New-Item -ItemType Directory -Path $tblActDir -Force | Out-Null
New-Item -ItemType Directory -Path $tblTestDir -Force | Out-Null

# index.ts (barrel)
@'
export { TableView } from "./components/table-view";
export { AddColumnModal } from "./components/add-column-modal";
export { CellEditor, CellDisplay } from "./components/cell-editor";
export { SummaryRow } from "./components/summary-row";
export {
  getColumns,
  getRows,
  addColumn,
  updateColumn,
  deleteColumn,
  addRow,
  updateCell,
  deleteRow,
} from "./actions";
export {
  formatCellValue,
  parseCellInput,
  evaluateFormula,
  computeSummary,
  getAutoFillValue,
} from "./cell-utils";
'@ | Set-Content -Path "$tblDir\index.ts" -Encoding UTF8

Write-Host "[Phase 2] Tables feature structure created." -ForegroundColor Green
Write-Host ""

# ── Create workspace pages ───────────────────────────────────
Write-Host "Creating workspace route pages..." -ForegroundColor Yellow

$wsPageDir = "src\app\(dashboard)\workspaces"
$wsIdDir = "$wsPageDir\[id]"
New-Item -ItemType Directory -Path $wsIdDir -Force | Out-Null

# workspaces/loading.tsx
@'
export default function WorkspacesLoading() {
  return (
    <div className="p-6 sm:p-8">
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <div className="h-8 w-40 animate-pulse rounded-lg bg-muted" />
            <div className="mt-2 h-4 w-24 animate-pulse rounded bg-muted" />
          </div>
          <div className="h-10 w-36 animate-pulse rounded-lg bg-muted" />
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <div className="flex flex-col gap-3 rounded-xl border border-border/50 p-5">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 animate-pulse rounded-lg bg-muted" />
              <div className="space-y-1.5">
                <div className="h-4 w-28 animate-pulse rounded bg-muted" />
                <div className="h-3 w-16 animate-pulse rounded bg-muted" />
              </div>
            </div>
            <div className="mt-4 h-3 w-20 animate-pulse rounded bg-muted" />
          </div>
        </div>
      </div>
    </div>
  );
}
'@ | Set-Content -Path "$wsPageDir\loading.tsx" -Encoding UTF8

Write-Host "Workspace pages created." -ForegroundColor Green
Write-Host ""

# ── Create migration directory ───────────────────────────────
Write-Host "Creating migration directory..." -ForegroundColor Yellow
$migDir = "supabase\migrations"
if (-not (Test-Path $migDir)) { New-Item -ItemType Directory -Path $migDir -Force | Out-Null }
Write-Host "Migration directory ready." -ForegroundColor Green
Write-Host ""

# ── Done ─────────────────────────────────────────────────────
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ALL PHASES APPLIED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: The component .tsx files (actions, workspace-card," -ForegroundColor Yellow
Write-Host "create-workspace-form, workspace-grid, table-view, cell-editor," -ForegroundColor Yellow
Write-Host "add-column-modal, summary-row, cell-utils) need to be extracted" -ForegroundColor Yellow
Write-Host "from the tar.gz files I gave you earlier into their folders." -ForegroundColor Yellow
Write-Host ""
Write-Host "This script created the folder structure + config files." -ForegroundColor Yellow
Write-Host "The .tsx component code is in the tar.gz downloads." -ForegroundColor Yellow
Write-Host ""
Write-Host "REMAINING MANUAL STEPS:" -ForegroundColor Cyan
Write-Host "  1. Run migration SQL in Supabase Dashboard -> SQL Editor" -ForegroundColor White
Write-Host "  2. Extract phase1 + phase2 tar.gz component files" -ForegroundColor White
Write-Host "  3. npm run dev" -ForegroundColor White
Write-Host "  4. npm run test" -ForegroundColor White
Write-Host ""
