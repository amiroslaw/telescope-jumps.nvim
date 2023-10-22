local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local actions_state = require 'telescope.actions.state'
local actions_set = require 'telescope.actions.set'

-- TODO maybe remove empty lines  and '-invalid-'
local function reverse(tab)
    for i = 1, #tab/2, 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
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

	for change in changes:gmatch '[^\r\n]+' do
		local match = change:gmatch('%d+')
		local nr = match()
		local row = match()
		local col = match()

		if row then
			table.insert(last_changes, { row = row, nr = nr, col = col, display = get_display(change, row) })
		end
	end
	return reverse(last_changes)
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
						lnum = tonumber(entry.row),
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
			attach_mappings = function(prompt_bufnr)
				actions_set.select:replace(function()
					local entry = actions_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.cmd(string.format('call cursor(%d,%d)', entry.lnum, entry.col + 1))
				end)
				return true
			end,
		}):find()
end

local function show_jumps(opts)
  opts = opts or {}
  local jumplist = vim.fn.getjumplist()[1]

  -- reverse the list
  local sorted_jumplist = {}
  for i = #jumplist, 1, -1 do
	if vim.api.nvim_buf_is_valid(jumplist[i].bufnr) and vim.fn.winbufnr(vim.fn.win_getid()) == jumplist[i].bufnr then
      jumplist[i].text = vim.api.nvim_buf_get_lines(jumplist[i].bufnr, jumplist[i].lnum - 1, jumplist[i].lnum, false)[1] or ""
      table.insert(sorted_jumplist, jumplist[i])
    end
  end

  pickers.new(opts, {
      prompt_title = "Jumplist",
      finder = finders.new_table {
        results = sorted_jumplist,
        entry_maker = make_entry.gen_from_quickfix(opts),
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
