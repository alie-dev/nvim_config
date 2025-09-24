-- keymaps.lua
local map = vim.keymap.set

local motions = require("motions")

-- <leader>를 스페이스로 전환

-- 버퍼 이동 (WezTerm: Cmd+Shift+[ / ] → Alt+H / Alt+L 로 전달)
map("n", "<M-{>", ":bprevious<CR>", { silent = true, desc = "Prev buffer" })
map("n", "<M-}>", ":bnext<CR>", { silent = true, desc = "Next buffer" })

-- Neo-tree 토글 (WezTerm: Cmd+1 → Alt+1)
map("n", "<M-1>", "<cmd>Neotree toggle left reveal_force_cwd<CR>", { silent = true, desc = "Toggle file tree" })

-- 버퍼 닫기
map("n", "<M-w>", "<cmd>confirm bdelete<CR>", { silent = true, desc = "Close buffer" })
-- 자신을 제외한 모든 버퍼 닫기
map("n", "<M-W>", "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", { silent = true })

-- 빈 줄 추가 / 라인 삭제
map("n", "<M-CR>", "o<Esc>", { silent = true, desc = "Add blank line below (stay)" })
map("n", "<M-BS>", "dd", { silent = true, desc = "Delete line (dd)" })

-- 버퍼라인 숫자 점프 (Space+1..9)
for i = 1, 9 do
	map("n", "<leader>" .. i, function()
		require("bufferline").go_to(i, true)
	end, { desc = "Go to buffer " .. i })
end

-- 스마트 모션(w/b)
map("n", "w", motions.smart_w_normal, { noremap = true, silent = true, desc = "Smart token toggle (UTF-8)" })
map("x", "w", motions.smart_w_visual, { noremap = true, silent = true, desc = "Smart token toggle (UTF-8)" })
map(
	"o",
	"w",
	motions.smart_w_operator,
	{ noremap = true, silent = true, expr = true, desc = "Smart token toggle (UTF-8)" }
)

map("n", "b", motions.smart_b_normal, { noremap = true, silent = true, desc = "Smart token reverse (UTF-8)" })
map("x", "b", motions.smart_b_visual, { noremap = true, silent = true, desc = "Smart token reverse (UTF-8)" })
map(
	"o",
	"b",
	motions.smart_b_operator,
	{ noremap = true, silent = true, expr = true, desc = "Smart token reverse (UTF-8)" }
)

-- Alt+h / Alt+l : 커서만 좌우 끝으로 (그대로 유지)
map({ "n", "x", "o" }, "<M-h>", function()
	vim.cmd("normal! 0")
end, { noremap = true, silent = true, desc = "Go line start (col 1)" })
map({ "n", "x", "o" }, "<M-l>", function()
	vim.cmd("normal! $")
end, { noremap = true, silent = true, desc = "Go line end ($)" })

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
map("n", "H", function()
	n_vis("h")
end, { noremap = true, silent = true, desc = "Visual: left" })
map("x", "H", function()
	x_vis("h")
end, { noremap = true, silent = true, desc = "Extend: left" })

pcall(vim.keymap.del, "x", "K")
pcall(vim.keymap.del, "n", "K")
map("n", "K", function()
	n_vis("k")
end, { noremap = true, silent = true, desc = "Visual: left" })
pcall(vim.keymap.del, "o", "K")
map("x", "K", function()
	x_vis("k")
end, { noremap = true, silent = true, desc = "Extend: left" })

map("n", "J", function()
	n_vis("j")
end, { noremap = true, silent = true, desc = "Visual: down" })
map("x", "J", function()
	x_vis("j")
end, { noremap = true, silent = true, desc = "Extend: down" })

map("n", "L", function()
	n_vis("l")
end, { noremap = true, silent = true, desc = "Visual: right" })
map("x", "L", function()
	x_vis("l")
end, { noremap = true, silent = true, desc = "Visual: right" })

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
map("n", "<leader>q", "<cmd>bdelete<CR>", { silent = true, desc = "Close buffer" })

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
map({ "n", "x" }, "<M-a>", "ggVG", { desc = "Select all" })

-- Neovim 0.11: get_clients로 대체

-- 그 함수, 클래스를 위주로 조사
vim.keymap.set("n", "gr", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if motions.lsp_supports(bufnr, "textDocument/references") then
		-- 지원 서버가 있으면 LSP 참조를 우선
		local ok, tb = pcall(require, "telescope.builtin")
		if ok then
			tb.lsp_references({ include_declaration = false, show_line = false })
		else
			vim.lsp.buf.references(nil, { loclist = true })
			vim.cmd("lopen") -- 목록창 열어주기
		end
	else
		-- 지원 서버 없으면 grep 폴백 (에러 안 뜸)
		local w = vim.fn.expand("<cword>")
		local ok, tb = pcall(require, "telescope.builtin")
		if ok then
			tb.grep_string({ search = w })
		else
			vim.cmd("silent! vimgrep /\\<" .. w .. "\\>/gj **/* | copen")
		end
	end
end, { silent = true, desc = "References (smart: LSP→Telescope/grep)" })

-- keymaps.lua (gd)
vim.keymap.set("n", "gd", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if motions.lsp_supports(bufnr, "textDocument/definition") then
		local ok, tb = motions.have("telescope.builtin")
		if ok then
			tb.lsp_definitions({ reuse_win = true })
		else
			vim.lsp.buf.definition()
		end
	else
		vim.notify("No LSP definitions for this buffer", vim.log.levels.WARN)
	end
end, { silent = true, desc = "LSP Definition" })

-- hover: 너는 'e'를 쓰고 있으니 그대로 유지 (충돌 감수)
vim.keymap.set("n", "e", function()
	local bufnr = 0
	if motions.lsp_supports(bufnr, "textDocument/hover") then
		vim.lsp.buf.hover()
	else
		vim.notify("No LSP provides hover for this buffer", vim.log.levels.WARN)
	end
end, { silent = true, desc = "Hover" })

-- rename
vim.keymap.set("n", "<leader>rn", function()
	local bufnr = 0
	if motions.lsp_supports(bufnr, "textDocument/rename") then
		vim.lsp.buf.rename()
	else
		vim.notify("No LSP provides rename for this buffer", vim.log.levels.WARN)
	end
end, { silent = true, desc = "Rename symbol" })

-- 일반 Code Action
vim.keymap.set({ "n", "v" }, "<leader>ca", function()
	vim.lsp.buf.code_action({ apply = false }) -- ✅ 미리보기/선택 후 적용
end, { desc = "Code Action (preview)" })

-- Organize Imports (미리보기)
vim.keymap.set("n", "<leader>co", function()
	vim.lsp.buf.code_action({
		context = { only = { "source.organizeImports" } },
		apply = false, -- ✅
	})
end, { desc = "Organize Imports (preview)" })

-- 다음/이전 진단(에러·경고 포함)
local float_opts = { border = "rounded", focus = false, source = "if_many" }

vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({ float = float_opts, wrap = true })
end, { desc = "Next diagnostic + popup" })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({ float = float_opts, wrap = true })
end, { desc = "Prev diagnostic + popup" })

-- 커서 위치의 에러/경고 설명 표시 (이동 X)
local float_opts = { border = "rounded", focus = false, source = "if_many" }
vim.keymap.set("n", "gl", function()
  vim.diagnostic.open_float(nil, float_opts) -- scope=cursor(기본 line). 둘 다 커서 주변에 뜸
end, { desc = "Show diagnostics here" })

-- 버퍼/프로젝트 전체 진단 목록(quickfix)
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostics → quickfix" })

-- <leader>f : 파일 전체 or 비주얼 선택영역 포맷
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({
		async = false,
		lsp_fallback = true,
		timeout_ms = 2000, -- 네가 opts에 준 값과 맞춰도 되고, 여기서만 다르게 줘도 됨
	})
end, { desc = "Format file or range (Conform)" })
-- -, _으로 범위 변경하는것은 webdev.lua의 페이지에nvim-treesitter.configs 내부에 설정되어있다
