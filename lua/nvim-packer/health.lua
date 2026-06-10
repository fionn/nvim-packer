local M = {}

function M.check()
    local prg = "packer"
    vim.health.start(prg)
    if vim.fn.executable(prg) == 1 then
        local path = vim.fn.exepath(prg)
        vim.health.ok(("%s is available (%s)"):format(prg, path))
    else
        vim.health.warn(("%s is not available"):format(prg))
    end
end

return M
