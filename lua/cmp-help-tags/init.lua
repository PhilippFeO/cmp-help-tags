local Path = require "plenary.path"
local utils = require "telescope.utils"

local M = {}

M.defaults = {
  -- TODO: It is probably better to let nvim-cmp control this option directly but currently I don't know how. <21-01-2024>
  filetypes = {}
}

M.cmp_items = {}

M.setup = function(opts)
  vim.validate({
    filetype = { opts.filetypes, 'table' }
  })
  M.defaults = vim.tbl_extend("force", M.defaults, opts)

  local langs = { 'en' }
  local langs_map = {}
  for _, lang in ipairs(langs) do
    langs_map[lang] = true
  end

  local tag_files = {}
  local function add_tag_file(lang, file)
    if langs_map[lang] then
      if tag_files[lang] then
        table.insert(tag_files[lang], file)
      else
        tag_files[lang] = { file }
      end
    end
  end

  local help_files = {}
  local all_files = vim.api.nvim_get_runtime_file("doc/*", true)
  for _, fullpath in ipairs(all_files) do
    local file = utils.path_tail(fullpath)
    if file == "tags" then
      add_tag_file("en", fullpath)
    elseif file:match "^tags%-..$" then
      local lang = file:sub(-2)
      add_tag_file(lang, fullpath)
    else
      help_files[file] = fullpath
    end
  end

  local tags = {}
  local tags_map = {}
  local delimiter = string.char(9)
  for _, lang in ipairs(langs) do
    for _, file in ipairs(tag_files[lang] or {}) do
      local lines = vim.split(Path:new(file):read(), "\n", true)
      for _, line in ipairs(lines) do
        -- TODO: also ignore tagComment starting with ';'
        if not line:match "^!_TAG_" then
          local fields = vim.split(line, delimiter, true)
          if #fields == 3 and not tags_map[fields[1]] then
            if fields[1] ~= "help-tags" or fields[2] ~= "tags" then
              table.insert(tags, {
                name = fields[1],
                filename = help_files[fields[2]],
                cmd = fields[3],
                lang = lang,
              })
              tags_map[fields[1]] = true
            end
          end
        end
      end
    end
  end

  --[[
    Example of element in table tags:
      {
        cmd = "/*lazy.nvim-lazy.nvim-installation*",
        filename = "/home/philipp/.local/share/nvim/lazy/lazy.nvim/doc/lazy.nvim.txt"
        lang ="en",
        name = "lazy.nvim-lazy.nvim-installation"
      }
  --]]

  for _, ht in ipairs(tags) do
    table.insert(M.cmp_items, {
      label = ht.name,
      documentation = {
        kind = "text",
        value = string.format('%s\n\nFilename:%s', ht.name, ht.filename)
      }
    })
  end

  local source = {}

  source.new = function()
    local self = setmetatable({ cache = {} }, { __index = source })

    return self
  end

  source.is_available = function()
    return vim.tbl_contains(M.defaults.filetypes, vim.bo.filetype)
    -- return vim.bo.filetype == 'markdown' or vim.bo.filetype == 'lua'
  end

  -- source.get_trigger_characters = function()
  --   return { "??" }
  -- end

  -- source.get_keyword_pattern = function()
  --   return 'lorem'
  -- end

  source.complete = function(_, _, callback)
    callback(M.cmp_items)
  end

  require('cmp').register_source("cmp_help_tags", source.new())


  -- pickers
  --     .new(opts, {
  --       prompt_title = "Help",
  --       finder = finders.new_table {
  --         results = tags,
  --         entry_maker = function(entry)
  --           return make_entry.set_default_entry_mt({
  --             value = entry.name .. "@" .. entry.lang,
  --             display = entry.name,
  --             ordinal = entry.name,
  --             filename = entry.filename,
  --             cmd = entry.cmd,
  --           }, opts)
  --         end,
  --       },
  --       previewer = previewers.help.new(opts),
  --       sorter = conf.generic_sorter(opts),
  --       attach_mappings = function(prompt_bufnr)
  --         action_set.select:replace(function(_, cmd)
  --           local selection = action_state.get_selected_entry()
  --           if selection == nil then
  --             utils.__warn_no_selection "builtin.help_tags"
  --             return
  --           end
  --
  --           actions.close(prompt_bufnr)
  --           if cmd == "default" or cmd == "horizontal" then
  --             vim.cmd("help " .. selection.value)
  --           elseif cmd == "vertical" then
  --             vim.cmd("vert help " .. selection.value)
  --           elseif cmd == "tab" then
  --             vim.cmd("tab help " .. selection.value)
  --           end
  --         end)
  --
  --         return true
  --       end,
  --     })
  --     :find()
end

return M
