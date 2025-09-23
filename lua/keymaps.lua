-- keymaps.lua
local map = vim.keymap.set

local motions = require("motions")
-- 버퍼 이동 (WezTerm: Cmd+Shift+[ / ] → Alt+H / Alt+L 로 전달)
map("n", "<M-{>", ":bprevious<CR>", { silent = true, desc = "Prev buffer" })
map("n", "<M-}>", ":bnext<CR>",     { silent = true, desc = "Next buffer" })

-- Neo-tree 토글 (WezTerm: Cmd+1 → Alt+1)
map("n", "<M-1>", "<cmd>Neotree toggle left reveal_force_cwd<CR>", { silent = true, desc = "Toggle file tree" })

-- 버퍼 닫기
map("n", "<M-w>", "<cmd>confirm bdelete<CR>", { silent = true, desc = "Close buffer" })
-- 자신을 제외한 모든 버퍼 닫기
map("n", "<M-W>", "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", { silent = true })


-- 빈 줄 추가 / 라인 삭제
map("n", "<M-CR>", "o<Esc>", { silent = true, desc = "Add blank line below (stay)" })
map("n", "<M-BS>", "dd",     { silent = true, desc = "Delete line (dd)" })

-- 버퍼라인 숫자 점프 (Space+1..9)
for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    require("bufferline").go_to(i, true)
  end, { desc = "Go to buffer " .. i })
end

-- 스마트 모션(w/b)
map("n", "w", motions.smart_w_normal,   { noremap = true, silent = true, desc = "Smart token toggle (UTF-8)" })
map("x", "w", motions.smart_w_visual,   { noremap = true, silent = true, desc = "Smart token toggle (UTF-8)" })
map("o", "w", motions.smart_w_operator, { noremap = true, silent = true, expr = true,  desc = "Smart token toggle (UTF-8)" })

map("n", "b", motions.smart_b_normal,   { noremap = true, silent = true, desc = "Smart token reverse (UTF-8)" })
map("x", "b", motions.smart_b_visual,   { noremap = true, silent = true, desc = "Smart token reverse (UTF-8)" })
map("o", "b", motions.smart_b_operator, { noremap = true, silent = true, expr = true,  desc = "Smart token reverse (UTF-8)" })

-- Alt+h / Alt+l : 커서만 좌우 끝으로 (그대로 유지)
map({ "n", "x", "o" }, "<M-h>", function() vim.cmd("normal! 0") end,
  { noremap = true, silent = true, desc = "Go line start (col 1)" })
map({ "n", "x", "o" }, "<M-l>", function() vim.cmd("normal! $") end,
  { noremap = true, silent = true, desc = "Go line end ($)" })

-- Alt+Shift+H / Alt+Shift+L : 선택 확장 (모드별로 동작 분리)
-- Normal: 비주얼 시작 후 확장 / Visual: 비주얼 유지한 채 확장
map("n", "<M-H>", "v0", { noremap = true, silent = true, desc = "Select to line start" })
map("x", "<M-H>", "0", { noremap = true, silent = true, desc = "Select to line start" })

map("n", "<M-L>", "v$", { noremap = true, silent = true, desc = "Select to line end" })
map("x", "<M-L>", "$", { noremap = true, silent = true, desc = "Select to line end" })

map({ "n", "x" }, ";", ":", { noremap = true, silent = false, desc = "Command-line" })

-- 2) f/t 반복키 재배치
map({ "n", "x", "o" }, "m", ",", { noremap = true, silent = true, desc = "Repeat f/t in reverse (prev)" })
map({ "n", "x", "o" }, ",", ";", { noremap = true, silent = true, desc = "Repeat f/t (next)" })

-- (선택) 마크 기능 대체: 필요 시 주석 해제
-- map({ "n", "x" }, "mm", "m", { noremap = true, silent = true, desc = "Mark (fallback)" })

-- 3) Shift+W/B → 비주얼 확장
map("n", "W", function()
  vim.cmd("normal! v")
  motions.smart_w_visual()
end, { noremap = true, silent = true, desc = "Visual smart-W" })
map("x", "W", motions.smart_w_visual, { noremap = true, silent = true, desc = "Visual smart-W" })

map("n", "B", function()
  vim.cmd("normal! v")
  motions.smart_b_visual()
end, { noremap = true, silent = true, desc = "Visual smart-B" })
map("x", "B", motions.smart_b_visual, { noremap = true, silent = true, desc = "Visual smart-B" })

-- helper: Normal → 비주얼 시작 후 count 만큼 이동
local function n_vis(dir)
  local cnt = vim.v.count > 0 and vim.v.count or 1
  vim.cmd(("normal! v%d%s"):format(cnt, dir))
end

-- helper: Visual → 선택을 count 만큼 확장
local function x_vis(dir)
  local cnt = vim.v.count > 0 and vim.v.count or 1
  vim.cmd(("normal! %d%s"):format(cnt, dir))
end

-- Shift+H/J/K/L : 비주얼 켜고 이동/확장
map("n", "H", function() n_vis("h") end, { noremap = true, silent = true, desc = "Visual: left" })
map("x", "H", function() x_vis("h") end, { noremap = true, silent = true, desc = "Extend: left" })

pcall(vim.keymap.del, "x", "K")
pcall(vim.keymap.del, "n", "K")
map("n", "K", function() n_vis("k") end, { noremap = true, silent = true, desc = "Visual: left" })
pcall(vim.keymap.del, "o", "K")
map("x", "K", function() x_vis("k") end, { noremap = true, silent = true, desc = "Extend: left" })

map("n", "J", function() n_vis("j") end, { noremap = true, silent = true, desc = "Visual: down" })
map("x", "J", function() x_vis("j") end, { noremap = true, silent = true, desc = "Extend: down" })

map("n", "L", function() n_vis("l") end, { noremap = true, silent = true, desc = "Visual: right" })
map("x", "L", function() x_vis("l") end, { noremap = true, silent = true, desc = "Visual: right" })



-- 🔑 LspAttach: 버퍼 로컬 LSP 키맵
local grp = vim.api.nvim_create_augroup("MyLspKeys", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = grp,
  callback = function(ev)
    local ok = pcall(function()
      local bufnr = ev.buf
      if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then return end

      local cid = ev.data and ev.data.client_id
      if not cid then return end
      local client = vim.lsp.get_client_by_id(cid)
      if not client then return end

      local function map_local(m, lhs, rhs, desc)
        if type(rhs) == "function" then
          vim.keymap.set(m, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
      end

      map_local("n", "gd", vim.lsp.buf.definition,        "LSP: Goto Definition")
      map_local("n", "e",  vim.lsp.buf.hover,              "LSP: Hover")
      map_local("n", "<leader>rn", vim.lsp.buf.rename,     "LSP: Rename")
      map_local("n", "<leader>ca", vim.lsp.buf.code_action,"LSP: Code Action")
      map_local("n", "gr", vim.lsp.buf.references,         "LSP: References")

      if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
        pcall(vim.lsp.inlay_hint.enable, bufnr, true)
      end
    end)
    if not ok then
      vim.schedule(function()
        vim.notify("LspAttach keymaps failed (suppressed). Check keymaps.lua", vim.log.levels.WARN)
      end)
    end
  end,
})

-- 현재만 남기고 전부 닫기
local function close_others_keep_current()
  local current = vim.api.nvim_get_current_buf()
  if vim.fn.exists(":BufferLineCloseOthers") == 2 then
    vim.cmd("BufferLineCloseOthers")
    return
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and b ~= current then
      pcall(vim.api.nvim_buf_delete, b, { force = false })
    end
  end
end
map("n", "<leader>Q", close_others_keep_current, { silent = true, desc = "Close all others" })
map("n", "<leader>q", "<cmd>bdelete<CR>",  { silent = true, desc = "Close buffer" })

-- Normal: % → 비주얼로 매칭까지 선택
map("n", "%", function()
  vim.cmd("normal! v%")
end, { noremap = true, silent = true, desc = "Visual select to matching pair" })

-- Alt+Shift+J/K 스왑
map("n", "<M-J>", "<cmd>m .+1<CR>==", { noremap = true, silent = true, desc = "Swap line with below" })
map("n", "<M-K>", "<cmd>m .-2<CR>==", { noremap = true, silent = true, desc = "Swap line with above" })

-- Visual 선택 이동
map("x", "<M-J>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
map("x", "<M-K>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })

-- 화면 스크롤
map({ "n", "x" }, "<M-j>", "<C-d>zz", { noremap = true, silent = true, desc = "Half-page down (center)" })
map({ "n", "x" }, "<M-k>", "<C-u>zz", { noremap = true, silent = true, desc = "Half-page up (center)" })

-- 전체 선택
map({ "n","x" }, "<M-a>", "ggVG", { desc = "Select all" })

-- -, _으로 범위 변경하는것은 webdev.lua의 페이지에nvim-treesitter.configs 내부에 설정되어있다

