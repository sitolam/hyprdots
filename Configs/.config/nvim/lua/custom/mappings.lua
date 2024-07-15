local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
    ["<leader>dus"] = {
      function ()
        local widgets = require('dap.ui.widgets');
        local sidebar = widgets.sidebar(widgets.scopes);
        sidebar.open();
      end,
      "Open debugging sidebar"
    },
    ["<leader>duc"] = { "<cmd> DapContinue <CR> "},
  }
}

M.crates = {
  plugin = true,
  n = {
    ["<leader>rcu"] = {
      function ()
        require('crates').upgrade_all_crates()
      end,
      "update crates"
    }
  }
}

M.rust = {
  n = {
    ["<leader>rr"] = { "<cmd> :!cargo run <CR>" },
  }
}

M.dart = {
  n = {
    ["<leader>rd"] = { "<cmd> :!dart run main.dart <CR>" },
  }
}

return M
