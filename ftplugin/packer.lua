---@param buf integer
local function format(buf)
    if vim.fn.executable("packer") == 0 then
        vim.notify("Skipping format as packer is missing", vim.log.levels.DEBUG)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local result = vim.system({"packer", "fmt", "-"}, {stdin = lines}):wait()

    if result.code ~= 0 then
        vim.opt_local.busy = vim.opt.busy:get() - 1
        vim.notify(("packer fmt exited with status %s: %s"):format(result.code,
            result.stderr), vim.log.levels.ERROR)
        return
    end

    local formatted = vim.split(result.stdout, "\n", {trimempty = false})
    table.remove(formatted)  -- Pop the last line as it's empty.

    if not vim.deep_equal(lines, formatted) then
        local view = vim.fn.winsaveview()
        pcall(vim.cmd.undojoin)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, formatted)
        vim.fn.winrestview(view)
    end
end

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("packer_format", {clear = true}),
    desc = "Format Packer",
    buffer = 0,
    callback = function(ev)
        vim.opt_local.busy = vim.opt.busy:get() + 1
        vim.api.nvim__redraw({buf = ev.buf, flush = true})
        if not pcall(format, ev.buf) then
            vim.notify("Error formatting buffer", vim.log.levels.ERROR)
        end
        vim.opt_local.busy = vim.opt.busy:get() - 1
    end
})
