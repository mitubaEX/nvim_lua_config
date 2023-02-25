plugin_files = {
  'plugins.editor',
  'plugins.completion',
  'plugins.git',
  'plugins.lang',
  'plugins.ui',
  'plugins.util',
}

modules = {}
for _, plugin_file in pairs(plugin_files) do
  for _, plugin in pairs(require(plugin_file)) do
    modules[#modules + 1] = plugin
  end
end

return modules
