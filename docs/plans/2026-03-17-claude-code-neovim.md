# Claude Code Neovim Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Setup `coder/claudecode.nvim` di NvChad v2.5 sehingga Claude Code bisa dibuka sebagai Neovim tab baru, support unlimited parallel sessions, dan NvimTree bisa toggle hide/show untuk clean workspace.

**Architecture:** Install `coder/claudecode.nvim` (MCP WebSocket protocol) dan `snacks.nvim` (dependency wajib) via Lazy.nvim. Claude terminal akan dikelola sebagai Neovim native tab sehingga bisa paralel dengan file editor tabs. Keybinding ditambah di `mappings.lua` tanpa mengganggu konfigurasi existing (smart-splits, tmux).

**Tech Stack:** Neovim 0.8+, NvChad v2.5, Lazy.nvim, `coder/claudecode.nvim`, `folke/snacks.nvim`

---

### Task 1: Install snacks.nvim

`snacks.nvim` adalah dependency wajib `claudecode.nvim`. Perlu ditambah ke plugins dulu.

**Files:**
- Modify: `~/.config/nvim/lua/plugins/init.lua`

**Step 1: Tambah snacks.nvim ke plugins**

Buka `~/.config/nvim/lua/plugins/init.lua`, tambah sebelum closing `}`:

```lua
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- minimal config, hanya yang dibutuhkan claudecode
      terminal = { enabled = true },
      notifier = { enabled = true },
    },
  },
```

**Step 2: Verifikasi syntax Lua valid**

Run di terminal:
```bash
nvim --headless -c "lua require('lazy')" -c "q" 2>&1 | head -20
```
Expected: tidak ada error merah, atau Neovim langsung quit clean.

**Step 3: Buka Neovim dan install**

```bash
nvim
```
Lazy.nvim akan auto-detect plugin baru. Ketik `:Lazy sync` untuk install.
Expected: `snacks.nvim` muncul di daftar installed plugins.

**Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/init.lua
git commit -m "feat: add snacks.nvim (claudecode dependency)"
```

---

### Task 2: Install claudecode.nvim

**Files:**
- Modify: `~/.config/nvim/lua/plugins/init.lua`

**Step 1: Tambah claudecode.nvim ke plugins**

Tambah setelah blok snacks.nvim di `lua/plugins/init.lua`:

```lua
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    opts = {
      -- terminal ditampilkan sebagai Neovim tab baru
      terminal_cmd = "tabnew | term",
      auto_start_server = true,
    },
    config = function(_, opts)
      require("claudecode").setup(opts)
    end,
  },
```

**Step 2: Install via Lazy**

```bash
nvim
```
Ketik `:Lazy sync`
Expected: `claudecode.nvim` muncul dan ter-install.

**Step 3: Cek health**

Di dalam Neovim:
```
:ClaudeCodeHealth
```
Expected: semua checks green (Claude Code CLI detected, WebSocket server OK).

Jika Claude Code CLI belum terdeteksi, pastikan `claude` ada di PATH:
```bash
which claude
```

**Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/init.lua
git commit -m "feat: install coder/claudecode.nvim"
```

---

### Task 3: Setup keybindings Claude Code

**Files:**
- Modify: `~/.config/nvim/lua/mappings.lua`

**Step 1: Tambah keybindings di mappings.lua**

Buka `~/.config/nvim/lua/mappings.lua`, tambah di bagian paling bawah:

```lua
-- Claude Code
-- Buka Claude session baru di tab baru
map({ "n", "t" }, "<leader>ac", function()
  require("claudecode").open()
end, { desc = "Claude open/toggle" })

-- Tambah Claude session paralel baru (tab baru terpisah)
map("n", "<leader>an", function()
  vim.cmd("tabnew")
  require("claudecode").open()
end, { desc = "Claude new parallel session" })

-- Navigasi antar tab: gt (next) dan gT (prev) sudah native Neovim
-- Tambah shortcut lebih cepat:
map("n", "<leader>]", "<cmd>tabnext<CR>", { desc = "tab next" })
map("n", "<leader>[", "<cmd>tabprev<CR>", { desc = "tab prev" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "tab close" })
```

**Step 2: Reload config**

```
:source ~/.config/nvim/lua/mappings.lua
```
Atau restart Neovim.

**Step 3: Test keybinding**

Tekan `<leader>ac` (default leader = `space`, jadi `Space+a+c`).
Expected: Claude Code terminal terbuka di tab baru.

Tekan `<leader>an`.
Expected: Tab baru lagi dengan Claude session terpisah — paralel session pertama.

Navigasi dengan `gt` / `gT` atau `Space+]` / `Space+[`.

**Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/mappings.lua
git commit -m "feat: add Claude Code keybindings"
```

---

### Task 4: NvimTree toggle clean workspace

NvimTree sudah punya toggle (`<C-n>`), tapi kita tambah shortcut khusus untuk "hide all untuk focus" mirip VS Code `Ctrl+B`.

**Files:**
- Modify: `~/.config/nvim/lua/mappings.lua`

**Step 1: Tambah keybinding hide/show sidebar**

Tambah di `mappings.lua` setelah blok Claude Code:

```lua
-- Toggle NvimTree hide/show (mirip VS Code Ctrl+B)
map("n", "<leader>e", function()
  local view = require("nvim-tree.view")
  if view.is_visible() then
    require("nvim-tree.api").tree.close()
  else
    require("nvim-tree.api").tree.open()
    -- Kembali ke editor window setelah open
    vim.cmd("wincmd p")
  end
end, { desc = "nvimtree toggle sidebar" })
```

Catatan: ini override mapping `<leader>e` yang ada (NvimTreeFocus) menjadi toggle + return focus ke editor.

**Step 2: Test**

Buka Neovim dengan file, tekan `Space+e`:
- Jika NvimTree visible → hilang, editor full width
- Jika NvimTree hidden → muncul, fokus kembali ke editor

**Step 3: Commit**

```bash
cd ~/.config/nvim
git add lua/mappings.lua
git commit -m "feat: NvimTree smart toggle (hide/show + keep editor focus)"
```

---

### Task 5: Verifikasi full workflow

**Step 1: Test skenario VS Code-like**

1. Buka Neovim dengan file: `nvim ~/Documents/02\ Dev/orbit/routes/api.php`
2. Buka file kedua: `:e routes/web.php` — muncul sebagai buffer tab di tabufline
3. Buka Claude: `Space+a+c` — muncul di **Neovim tab baru** di atas
4. Switch kembali ke editor: `gT`
5. Buka Claude session paralel: `Space+a+n` — tab ketiga
6. Toggle NvimTree: `Space+e` — sidebar hilang, clean workspace

Expected behavior:
- Tab bar atas menunjukkan semua tab: `[routes/api.php] [>_ Claude] [>_ Claude 2]`
- Navigasi antar tab smooth dengan `gt/gT`
- NvimTree toggle tidak ganggu tab lain

**Step 2: Test MCP protocol**

Di dalam Claude terminal tab, ketik:
```
/help
```
Expected: Claude Code merespons dan bisa "melihat" file yang sedang kamu edit di tab lain (karena MCP WebSocket aktif).

**Step 3: Test parallel sessions**

Buka 2 Claude tabs, jalankan dua task berbeda secara paralel.
Expected: keduanya independent, tidak saling mengganggu.

---

## Catatan Penting

- **Conflict `<C-h>` di terminal mode:** smart-splits pakai `<C-h/j/k/l>` untuk navigasi. Di dalam Claude terminal tab, gunakan `<C-x>` dulu untuk keluar terminal mode, baru navigasi.
- **Jika `claudecode.nvim` gagal health check:** pastikan Claude Code CLI versi terbaru (`claude --version`).
- **Tab vs Buffer:** NvChad tabufline (baris tab di atas) menampilkan *buffers*, bukan *tabs*. Neovim native tabs ada di level lebih tinggi. Keduanya bisa aktif bersamaan — buffers untuk file di dalam 1 tab, native tabs untuk workspace berbeda (editor vs claude).
