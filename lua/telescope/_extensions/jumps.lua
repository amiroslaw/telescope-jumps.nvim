local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local actions_state = require 'telescope.actions.state'
local actions_set = require 'telescope.actions.set'

-- TODO maybe remove empty lines  and '-invalid-'
local function reverse(tab)
	for i = 1, #tab / 2, 1 do
		tab[i], tab[#tab - i + 1] = tab[#tab - i + 1], tab[i]
	end
	return tab
end

local function get_display(line, row)
	-- return vim.trim(line)
	return row .. ': ' .. line:sub(18)
end

local function get_changes()
	local last_changes = {}
	local changes = vim.api.nvim_command_output 'changes'
	local hash = {}

	for change in changes:gmatch '[^\r\n]+' do
		local match = change:gmatch '%d+'
		local nr = match()
		local row = match()
		local col = match()

		if row and not hash[row] then
			hash[row] = true -- remove duplicates
			table.insert(last_changes, { lnum = row, nr = nr, col = col, display = get_display(change, row) })
		end
	end
	return reverse(last_changes)

	-- simpler but doesn't work
	-- local changes = vim.fn.getchangelist(vim.api.nvim_get_current_buf())[1]
	--  for i = #changes, 1, -1 do
	--   changes[i].display = vim.api.nvim_buf_get_lines(0, changes[i].lnum - 1, changes[i].lnum, false)[1] or ""
	--  end
end

local function show_changes(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	opts = opts or {}

	pickers.new(opts, {
			prompt_title = 'Changes',
			finder = finders.new_table {
				results = get_changes(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.display,
						-- ordinal = tostring(entry.nr),
						lnum = tonumber(entry.lnum),
						col = tonumber(entry.col),
						filename = filepath,
						bufnr = bufnr,
					}
				end,
			},
			previewer = conf.grep_previewer(opts),
			-- previewer = conf.qflist_previewer(opts),
			sorter = conf.generic_sorter(opts),
			-- sorting_strategy = "ascending",
			-- attach_mappings = function(prompt_bufnr)
			-- 	actions_set.select:replace(function()
			-- 		local entry = actions_state.get_selected_entry()
			-- 		actions.close(prompt_bufnr)
			-- 		vim.cmd(string.format('call cursor(%d,%d)', entry.value.row, entry.value.col + 1))
			-- 	end)
			-- 	return true
			-- end,
		}):find()
end

local function get_jumplist()
	local jumplist = vim.fn.getjumplist()[1]

	local current_buffer = vim.fn.winbufnr(vim.fn.win_getid())
	-- reverse the list
	local sorted_jumplist = {}
	for i = #jumplist, 1, -1 do
		if vim.api.nvim_buf_is_valid(jumplist[i].bufnr) and current_buffer == jumplist[i].bufnr then
			local text = vim.api.nvim_buf_get_lines(jumplist[i].bufnr, jumplist[i].lnum - 1, jumplist[i].lnum, false)[1]
			if text then
				jumplist[i].display = jumplist[i].lnum .. ': ' .. text
				table.insert(sorted_jumplist, jumplist[i])
			end
		end
	end
	return sorted_jumplist
end

local function show_jumps(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	opts = opts or {}

	pickers.new(opts, {
			prompt_title = 'Jumpbuff',
			finder = finders.new_table {
				results = get_jumplist(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.display,
						lnum = tonumber(entry.lnum),
						filename = filepath,
						bufnr = bufnr,
					}
				end,
			},
			previewer = conf.qflist_previewer(opts),
			sorter = conf.generic_sorter(opts),
		}):find()
end

return require('telescope').register_extension {
	exports = {
		changes = show_changes,
		jumpbuff = show_jumps,
	},
}
