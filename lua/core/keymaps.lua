local map = vim.keymap.set
local terminal = require("core.terminal")

local function opts(desc)
	return { noremap = true, silent = true, desc = desc }
end

-- Basics
map("n", ";", ":", { desc = "Command mode" })
map("i", "jk", "<Esc>", opts("Exit insert mode"))
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<cr>", opts("Save file"))
map("n", "<Esc>", "<cmd>nohlsearch<cr>", opts("Clear search highlight"))
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts("Terminal normal mode"))

-- Confirmed quit: Ctrl+Q, then q/y.
map("n", "<C-q>", function()
	vim.api.nvim_echo({
		{ "Exit Neovim? ", "WarningMsg" },
		{ "press q or y to confirm", "MoreMsg" },
		{ " (anything else cancels)", "Comment" },
	}, false, {})

	local ok, key = pcall(vim.fn.getcharstr)

	vim.cmd("redraw")

	if not ok then
		return
	end

	if key == "q" or key == "Q" or key == "y" or key == "Y" then
		-- getcharstr() temporarily puts Neovim under textlock.
		-- Defer :qall until the current key-processing cycle is finished.
		vim.schedule(function()
			local quit_ok, err = pcall(vim.cmd, "confirm qall")

			if not quit_ok then
				vim.notify("Could not exit Neovim:\n" .. tostring(err), vim.log.levels.ERROR)
			end
		end)
	else
		vim.notify("Exit cancelled", vim.log.levels.INFO)
	end
end, opts("Quit Neovim (confirm)"))

-- VS Code-like search
map("n", "<C-p>", function()
	Snacks.picker.files({ hidden = true })
end, opts("Find files"))

map("n", "<C-f>", function()
	Snacks.picker.lines()
end, opts("Find in current file"))

map("n", "<C-S-f>", function()
	Snacks.picker.grep({ hidden = true })
end, opts("Find in project"))

map("n", "<leader><space>", function()
	Snacks.picker.smart()
end, opts("Smart find"))
map("n", "<leader>ff", function()
	Snacks.picker.files({ hidden = true })
end, opts("Find files"))
map("n", "<leader>fg", function()
	Snacks.picker.grep({ hidden = true })
end, opts("Grep project"))
map("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, opts("Buffers"))
map("n", "<leader>fr", function()
	Snacks.picker.recent()
end, opts("Recent files"))
map({ "n", "x" }, "<leader>fw", function()
	Snacks.picker.grep_word()
end, opts("Find word or selection"))
map("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, opts("Find keymaps"))
map("n", "<leader>fh", function()
	Snacks.picker.help()
end, opts("Help pages"))
map("n", "<leader>/", function()
	Snacks.picker.grep({ hidden = true })
end, opts("Grep project"))

-- Explorer and buffers
local function toggle_explorer()
	local pickers = Snacks.picker.get({ source = "explorer" })

	if #pickers > 0 then
		for _, picker in ipairs(pickers) do
			picker:close()
		end
		return
	end

	Snacks.explorer()
end

map("n", "<C-b>", toggle_explorer, opts("Toggle file explorer"))
map("n", "<C-n>", "<cmd>enew<cr>", opts("New buffer"))
map("n", "<C-w>", function()
	Snacks.bufdelete()
end, opts("Delete current buffer"))
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, opts("Delete current buffer"))
map("n", "<leader>bo", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
		if buffer ~= current and vim.bo[buffer].buflisted then
			pcall(Snacks.bufdelete, buffer)
		end
	end
end, opts("Delete other buffers"))
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", opts("Previous buffer"))
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", opts("Next buffer"))

for index = 1, 9 do
	map("n", "<C-" .. index .. ">", function()
		vim.cmd("BufferLineGoToBuffer " .. index)
	end, opts("Go to buffer " .. index))
end

-- Fast window navigation.
map("n", "<C-h>", "<C-w>h", opts("Window left"))
map("n", "<C-j>", "<C-w>j", opts("Window down"))
map("n", "<C-k>", "<C-w>k", opts("Window up"))
map("n", "<C-l>", "<C-w>l", opts("Window right"))

-- Windows: Alt+W is the window-command prefix because Ctrl+W closes buffers.
map("n", "<A-w>h", "<C-w>h", opts("Window left"))
map("n", "<A-w>j", "<C-w>j", opts("Window down"))
map("n", "<A-w>k", "<C-w>k", opts("Window up"))
map("n", "<A-w>l", "<C-w>l", opts("Window right"))
map("n", "<A-w>w", "<C-w>w", opts("Next window"))
map("n", "<A-w>v", "<C-w>v", opts("Vertical split"))
map("n", "<A-w>s", "<C-w>s", opts("Horizontal split"))
map("n", "<A-w>q", "<C-w>c", opts("Close window"))
map("n", "<A-w>=", "<C-w>=", opts("Equalize windows"))

-- The same Alt+W prefix works while typing in a terminal.
map("t", "<A-w>h", "<C-\\><C-n><C-w>h", opts("Window left"))
map("t", "<A-w>j", "<C-\\><C-n><C-w>j", opts("Window down"))
map("t", "<A-w>k", "<C-\\><C-n><C-w>k", opts("Window up"))
map("t", "<A-w>l", "<C-\\><C-n><C-w>l", opts("Window right"))
map("t", "<A-w>w", "<C-\\><C-n><C-w>w", opts("Next window"))
map("t", "<A-w>q", "<C-\\><C-n><C-w>c", opts("Close window"))

map("n", "<leader>wv", "<cmd>vsplit<cr>", opts("Vertical split"))
map("n", "<leader>ws", "<cmd>split<cr>", opts("Horizontal split"))
map("n", "<leader>wq", "<cmd>close<cr>", opts("Close window"))
map("n", "<leader>w=", "<C-w>=", opts("Equalize windows"))

-- Terminals: three independent persistent sessions
map({ "n", "t" }, "<C-`>", terminal.float, opts("Floating terminal"))
map({ "n", "t" }, "<C-e>", terminal.right, opts("Right terminal"))
map("n", "<leader>tb", terminal.bottom, opts("Bottom terminal"))
map("n", "<leader>tr", terminal.right, opts("Right terminal"))
map("n", "<leader>tf", terminal.float, opts("Floating terminal"))
map("n", "<leader>tn", terminal.new_bottom, opts("New bottom terminal"))
map("n", "<leader>tt", terminal.tab, opts("Terminal tab"))
map("n", "<leader>tl", terminal.list, opts("Terminal sessions"))

-- Editing
map("n", "<leader>c", function()
	local path = vim.fn.expand("%:.")
	if path == "" then
		vim.notify("Current buffer is not a file", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", path)
	vim.fn.setreg("*", path)
	vim.notify("Copied: " .. path)
end, opts("Copy relative file path"))

map("n", "<leader>d", "yyp", opts("Duplicate line"))
map("n", "<A-j>", "<cmd>move .+1<cr>==", opts("Move line down"))
map("n", "<A-k>", "<cmd>move .-2<cr>==", opts("Move line up"))
map("x", "<A-j>", ":move '>+1<cr>gv=gv", opts("Move selection down"))
map("x", "<A-k>", ":move '<-2<cr>gv=gv", opts("Move selection up"))
map("i", "<A-j>", "<Esc><cmd>move .+1<cr>==gi", opts("Move line down"))
map("i", "<A-k>", "<Esc><cmd>move .-2<cr>==gi", opts("Move line up"))

map("n", "<C-S-Down>", "<cmd>move .+1<cr>==", opts("Move line down"))
map("n", "<C-S-Up>", "<cmd>move .-2<cr>==", opts("Move line up"))
map("x", "<C-S-Down>", ":move '>+1<cr>gv=gv", opts("Move selection down"))
map("x", "<C-S-Up>", ":move '<-2<cr>gv=gv", opts("Move selection up"))
map("i", "<C-S-Down>", "<Esc><cmd>move .+1<cr>==gi", opts("Move line down"))
map("i", "<C-S-Up>", "<Esc><cmd>move .-2<cr>==gi", opts("Move line up"))

local function format()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end
map({ "n", "x" }, "<C-S-i>", format, opts("Format file or selection"))
map({ "n", "x" }, "<leader>cf", format, opts("Format file or selection"))

-- Visual surround: select text and press a delimiter directly.
-- Uses nvim-surround's Visual-mode S mapping underneath.
for _, spec in ipairs({
	{ "(", ")" },
	{ ")", ")" },
	{ "[", "]" },
	{ "]", "]" },
	{ "{", "}" },
	{ "}", "}" },
	{ '"', '"' },
	{ "'", "'" },
	{ "`", "`" },
}) do
	local key, surround = spec[1], spec[2]
	map("x", key, "S" .. surround, {
		remap = true,
		silent = true,
		desc = "Surround selection with " .. key,
	})
end

-- Cycle quotes inside the nearest parentheses: " -> ' -> ` -> ".
map("n", "<leader>q", function()
	vim.cmd.normal({ "yi(", bang = true })
	local text_inside = vim.fn.getreg("0")

	local first = text_inside:sub(1, 1)
	local last = text_inside:sub(-1)
	local body = text_inside

	if (first == '"' or first == "'" or first == "`") and first == last then
		body = text_inside:sub(2, -2)
	end

	local new_q
	if first == '"' then
		new_q = "'"
	elseif first == "'" then
		new_q = "`"
	else
		new_q = '"'
	end

	vim.cmd.normal({ "ci(", bang = true })
	vim.api.nvim_put({ new_q .. body .. new_q }, "c", true, true)
end, opts("Cycle quotes inside ()"))

-- Find and replace
map("n", "<leader>sr", "<cmd>GrugFar<cr>", opts("Search and replace"))
map("x", "<leader>sr", ":GrugFar<cr>", opts("Search and replace selection"))
map("x", "<leader>sR", ":GrugFarWithin<cr>", opts("Replace within selection"))
map("n", "<leader>sw", function()
	require("grug-far").open({
		prefills = { search = vim.fn.expand("<cword>") },
	})
end, opts("Replace word under cursor"))

-- Diagnostics
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, opts("Next diagnostic"))
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, opts("Previous diagnostic"))
map("n", "<leader>xx", function()
	Snacks.picker.diagnostics()
end, opts("Workspace diagnostics"))
map("n", "<leader>xX", function()
	Snacks.picker.diagnostics_buffer()
end, opts("Buffer diagnostics"))

-- Visual mode: indent/outdent selection and keep selection active.
map("x", "<Tab>", ">gv", opts("Indent selection"))
map("x", "<S-Tab>", "<gv", opts("Outdent selection"))

-- Select mode: switch to Visual mode first, then indent/outdent.
map("s", "<Tab>", "<C-g>>gv", opts("Indent selection"))
map("s", "<S-Tab>", "<C-g><gv", opts("Outdent selection"))
