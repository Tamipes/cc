local gurl_parameters = {
  ["ls"] = {},
  ["install"] = {},
  ["update"] = {},
  ["del"] = {},
}

local function tabCompletionFunction(shell, parNumber, curText, lastText)
  -- Check that the parameters entered so far are valid:
  local curParam = gurl_parameters
  for i = 2, #lastText do
    if curParam[lastText[i] .. " "] then
      curParam = curParam[lastText[i] .. " "]
    else
      return { "" }
    end
  end

  -- Check for suitable words for the current parameter:
  local results = {}
  for word, _ in pairs(curParam) do
    if word:sub(1, #curText) == curText then
      results[#results + 1] = word:sub(#curText + 1)
    end
  end
  return results
end
shell.setCompletionFunction(".tami/bin/gurl", tabCompletionFunction)
