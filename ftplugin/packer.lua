---@type vim.SystemObj[]
local jobs = {}

---@param buf integer
local function format(buf)
    if vim.fn.executable("packer") == 0 then
        vim.notify("Skipping format as packer is missing", vim.log.levels.DEBUG)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local job = vim.system({"packer", "fmt", "-"}, {stdin = lines}, function(out)
        vim.schedule(function()
            vim.opt_local.readonly = false
            vim.opt_local.busy = vim.opt.busy:get() - 1

            if out.code ~= 0 then
                vim.notify(("packer fmt exited with status %s: %s"):format(out.code,
                    out.stderr), vim.log.levels.ERROR)
                return
            end

            local formatted = vim.split(out.stdout, "\n", {trimempty = false})
            table.remove(formatted)  -- Pop the last line as it's empty.

            if not vim.deep_equal(lines, formatted) then
                local view = vim.fn.winsaveview()
                pcall(vim.cmd.undojoin)
                vim.api.nvim_buf_set_lines(buf, 0, -1, true, formatted)
                vim.fn.winrestview(view)
            end

            vim.api.nvim__redraw({buf = buf, flush = true})
        end)
    end)
    table.insert(jobs, job)
end

local augroup = vim.api.nvim_create_augroup("packer_format", {clear = true})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Format Packer",
    buffer = 0,
    callback = function(ev)
        ---@type integer
        vim.opt_local.busy = vim.opt.busy:get() + 1
        vim.opt_local.readonly = true

        if not pcall(format, ev.buf) then
            vim.notify("Error formatting buffer", vim.log.levels.ERROR)
        end
    end
})

vim.api.nvim_create_autocmd("ExitPre", {
    group = augroup,
    desc = "Wait for packer format",
    callback = function(_)
        for _, job in ipairs(jobs) do
            job:wait(10000)
        end
    end
})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
    .. "\n autocmd! packer_format BufWritePre"
