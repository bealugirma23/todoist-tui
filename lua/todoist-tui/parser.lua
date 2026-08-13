local M = {}

-- Strip trailing punctuation (e.g. "@work," -> "@work")
local function strip_punctuation(str)
  return str:gsub("[%.,:;!%?%)%]}]+$", "")
end

function M.parse(text)
  local result = {
    content = "",
    project = nil,
    tags = {},
    priority = nil, -- will be 1, 2, 3, or 4 if specified (where 1 is highest, e.g. p1)
  }

  if not text or text == "" then
    return result
  end

  local words = vim.split(text, "%s+")
  local content_words = {}

  for _, raw_word in ipairs(words) do
    if raw_word ~= "" then
      local word = strip_punctuation(raw_word)

      if word:match("^#.+") then
        -- First project reference wins; ignore subsequent ones so they don't pollute content
        if not result.project then
          result.project = word:sub(2)
        end
      elseif word:match("^@.+") then
        table.insert(result.tags, word:sub(2))
      elseif word:lower():match("^p[1234]$") then
        -- p1, p2, p3, or p4 (case-insensitive)
        if not result.priority then
          result.priority = tonumber(word:sub(2))
        end
      else
        table.insert(content_words, raw_word)
      end
    end
  end

  result.content = table.concat(content_words, " ")

  return result
end

return M
