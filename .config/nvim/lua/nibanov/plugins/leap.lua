return {
  { -- Text navigation plugin
    'ggandor/leap.nvim',
    opts = {},
    config = function()
        local leap = require 'leap'
        leap.create_default_mappings()
    end,
  },
}
