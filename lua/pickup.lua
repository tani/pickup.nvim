local M = {}

function M.setup(_opts)
  M.opts = vim.tbl_extend('keep', _opts or {}, {
    match_hl_group = 'DiffAdd',
    select_hl_group = 'PmenuSel',
    border_hl_group = 'FloatBorder',
    border_style = 'rounded',
    lhs = '<C-p>'
  })
  if M.opts.lhs ~= '' then
    vim.keymap.set('n', M.opts.lhs, M.pickup, {})
  end
end

local extmark_id = vim.api.nvim_create_namespace('pickup')

function M.pickup()
  local Popup = require('nui.popup')
  local Input = require('nui.input')
  local event = require('nui.utils.autocmd').event
  local path = ""
  local popup = Popup({
    border = { style = M.opts.border_style },
    position = {
      row = 5,
      col = '50%'
    },
    size = {
      width = '50%',
      height = '60%'
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:" .. M.opts.border_hl_group
    }
  })
  popup:mount()
  local input = Input({
    position = {
      row = 2,
      col = '50%'
    },
    size = {
      width = '50%'
    },
    border = { style = M.opts.border_style },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:" .. M.opts.border_hl_group
    }
  }, {
    prompt = 'pattern: ',
    on_submit = function()
      if path ~= "" then
        vim.cmd.edit({ args = { path }})
      end
    end,
    on_change = function(value)
      local files = {}
      for file in vim.fs.dir(vim.fn.getcwd(), { depth = 256 }) do
        table.insert(files, file)
      end
      local result = vim.fn.matchfuzzypos(files, value, { limit = 256 })
      files = value == "" and files or result[1]
      path = #files > 0 and vim.fs.normalize(vim.fn.getcwd() .. '/' .. files[1]) or ""
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {})
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, files)
        vim.api.nvim_buf_clear_namespace(popup.bufnr, extmark_id, 0, -1)
        if #files > 0 then
          vim.api.nvim_buf_set_extmark(
            popup.bufnr,
            extmark_id,
            0, 0,
            {
              end_col = #files[1],
              hl_group = M.opts.select_hl_group
           }
          )
        end
        for i, pos in ipairs(result[2]) do
          for _, j in ipairs(pos) do
            vim.api.nvim_buf_set_extmark(
              popup.bufnr,
              extmark_id,
              i - 1, j,
              {
                end_col = j + 1,
                hl_group = M.opts.match_hl_group
              }
            )
          end
        end
      end)
    end
  })
  for _, mode in ipairs({ "i", "n" }) do
    input:map(mode, "<C-c>", function()
      input:hide()
      input:unmount()
    end, { noremap = true })
  end
  input:on(event.BufLeave, function()
    popup:hide()
    popup:unmount()
  end)
  input:mount()
end

return M
