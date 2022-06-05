local list = function(name)
  for k, _ in pairs(package.loaded) do
    if string.match(k, name) then
      print('Found "' .. k .. '"')
    end
  end
end

local unload = function(name)
  if package.loaded[name] then
    package.loaded[name] = nil
    print('Unloaded "' .. name .. '"')
    return true
  else
    print('Package "' .. name .. '" is not loaded')
    return false
  end
end

local reload = function(name)
  if unload(name) then
    require(name)
    print('Reloaded "' .. name .. '"')
  end
end

return {
  list = list,
  unload = unload,
  reload = reload,
}
