function to_string(any)
  if type(any)=="function" then return "function" end
  if any==nil then return "nil" end
  if type(any)=="string" then return any end
  if type(any)=="boolean" then return any and "true" or "false" end
  if type(any)=="number" then return ""..any end
  if type(any)=="table" then -- recursion
    local str = "{ "
    for k,v in pairs(any) do
      str=str..to_string(k).."->"..to_string(v).." "
    end
    return str.."}"
  end
  return "unkown" -- should never show
end
