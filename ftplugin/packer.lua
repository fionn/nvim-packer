if vim.fn.executable("packer") == 1 then
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("packer_format", {clear = true}),
        desc = "Format Packer",
        buffer = 0,
        callback = function(ev)
            local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, true)
            local result = vim.system({"packer", "fmt", "-"}, {stdin = lines}):wait()
            if result.code ~= 0 then
                vim.notify("packer fmt: " .. result.stderr, vim.log.levels.ERROR)
                return
            end

            local formatted = vim.split(result.stdout, "\n", {trimempty = false})
            table.remove(formatted)  -- Pop the last line as it's empty.

            if not vim.deep_equal(lines, formatted) then
                local view = vim.fn.winsaveview()
                pcall(vim.cmd.undojoin)
                vim.api.nvim_buf_set_lines(ev.buf, 0, -1, true, formatted)
                vim.fn.winrestview(view)
            end
        end
    })
end
