local M = {}
local H = {}

---@alias telescope-directory._finder.Cmd table

local cmds = {
    ["fd"] = { "fd", "--type", "d", "--color", "never" },
    ["fdfind"] = { "fdfind", "--type", "d", "--color", "never" },
    ["find"] = { "find", ".", "-type", "d" },
}

---@param finder_cmd telescope-directory.FinderCmd
---@param opts telescope-directory.SearchOptions
function M.get(finder_cmd, opts)
    if nil == finder_cmd then
        finder_cmd = H.get_default_finder_cmd()
    end

    if "function" == type(finder_cmd) then
        return require("telescope.finders").new_oneshot_job(finder_cmd(opts))
    end

    local cmd = H.get_cmd(finder_cmd, opts)
    if nil == cmd then
        error(("Could not create finder for %q!"):format(finder_cmd))
    end
    return require("telescope.finders").new_oneshot_job(cmd)
end

---@return telescope-directory.FinderCmd
function H.get_default_finder_cmd()
    for executable, _ in pairs(cmds) do
        if 1 == vim.fn.executable(executable) then
            return executable
        end
    end

    return nil
end

---@param finder_cmd telescope-directory.FinderCmd
---@param opts telescope-directory.SearchOptions
---@return telescope-directory._finder.Cmd|nil
function H.get_cmd(finder_cmd, opts)
    local cmd = cmds[finder_cmd]
    if not cmd then
        return nil
    end

    if 1 ~= vim.fn.executable(finder_cmd) then
        error(("You don't have %q executable!"):format(finder_cmd))
    end

    cmd = vim.deepcopy(cmd)
    if finder_cmd == "fd" or finder_cmd == "fdfind" then
        if opts.follow then
            cmd[#cmd + 1] = "-L"
        end
        if opts.hidden then
            cmd[#cmd + 1] = "--hidden"
        end
        if opts.no_ignore then
            cmd[#cmd + 1] = "--no-ignore"
        end
        if opts.no_ignore_parent then
            cmd[#cmd + 1] = "--no-ignore-parent"
        end
    elseif finder_cmd == "find" then
        ---@param opt string
        local not_available = function(opt)
            vim.notify(
                ("The %q key is not available for the `find` command in `directory`."):format(opt),
                vim.log.levels.WARN
            )
        end

        if opts.follow then
            table.insert(cmd, 2, "-L")
        end
        if not opts.hidden then
            vim.list_extend(cmd, { "-not", "-path", "*/.*" })
        end
        if nil ~= opts.no_ignore then
            not_available("no_ignore")
        end
        if nil ~= opts.no_ignore_parent then
            not_available("no_ignore_parent")
        end
    end

    return cmd
end

return M
