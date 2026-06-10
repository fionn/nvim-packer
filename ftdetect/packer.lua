-- We detect Packer files via an autocommand rather than using the recommended
-- vim.filetype.add mechanism because the latter fails to override the default
-- hcl filetype, possibly due to an interaction with hashivim/vim-terraform,
-- which we want to coexist with.

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Set Packer filetype",
    pattern = {"*.pkr.hcl"},
    callback = function()
        vim.opt_local.filetype = "packer.hcl"
    end
})
