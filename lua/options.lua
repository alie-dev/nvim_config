vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.showmode = false

vim.opt.linespace = 50
-- init.lua 등
vim.opt.expandtab = true -- 탭 대신 스페이스 입력
vim.opt.shiftwidth = 2 -- 자동 들여쓰기 폭
vim.opt.tabstop = 2 -- 탭 표시 폭
vim.opt.softtabstop = 2

-- 디스크 변경 자동 반영
vim.opt.autoread = true

-- 외부 변화 감지 함수
-- 포커스 돌아오거나 버퍼/커서 머물 때 타임스탬프 체크 → 변경 시 자동 :edit
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		-- 커맨드라인 입력 중이 아니면
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- 디스크에서 바뀐 뒤(리로드 후) 알림
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	callback = function(ev)
		vim.notify("Reloaded from disk: " .. ev.file, vim.log.levels.INFO)
	end,
})
