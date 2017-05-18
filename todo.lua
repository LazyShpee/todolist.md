local config = require('config')
config.port = config.port or 8000
config.domain = config.domain or '0.0.0.0'
config.paths = config.paths or {"./%s.md"}

local fs = require('fs')
local static = require('weblit-static')
local template = require('libs.template')
template.caching(false)

local function strip(str) return str and str:gsub('^%s+', ''):gsub('%s+$', '') end
local function standard(str) return str and str:lower():gsub('[^a-zA-Z0-9]', '-') end
local function style(target, what, val)
  if val then
    return string.format('%s\n {\n%s: %s;\n}\n', target, what, val)
  end
  return ''
end
local function split()
local function parse(lines)
  local options = {colors = {projects = {}, categories = {}}, links = {}}
  local data = {}
  local mode = 'options'
  for i, v in ipairs(lines) do
    repeat
      if v == "---" then
        mode = 'data'
        break
      end
      if mode == 'options' then
        if v:find('^([a-zA-Z_][a-zA-Z0-9_]*)%s*:%s*(%S.-)%s*$') then
          local n, v = v:match('^([a-zA-Z_][a-zA-Z0-9_]*)%s*:%s*(%S.-)%s*$')
          if not options[n] then
            options[n] = v
          end
        elseif v:find('%b[]%b{}') then
          local p, c = v:match('(%b[])(%b{})')
          options.colors.projects[standard(p:sub(2, -2))] = strip(c:sub(2, -2))
        elseif v:find('%b()%b{}') then
          local p, c = v:match('(%b())(%b{})')
          options.colors.categories[standard(p:sub(2, -2))] = strip(c:sub(2, -2))
        elseif v:find('%b<>%b{}') then
          local p, c = v:match('(%b<>)(%b{})')
          options.links[p:sub(2, -2)] = strip(c:sub(2, -2))
        end
      elseif mode == 'data' then
        local tmp = strip(v:sub(2))
        if v:sub(1,1) == '#' then
          local cat = {labels = {}}
          tmp = tmp:gsub('<(.+)>', function(m)
            cat.link = m
            return ''
          end):gsub('(%b[])%s*$', function (m)
            table.insert(cat.labels, m:sub(2, -2))
            return ''
          end)
          if tmp:find('^%[%-%]') then
            cat.title = strip(tmp:sub(4))
            cat.collapse = true
          else
            cat.title = strip(tmp)
            cat.collapse = false
          end
          data[#data + 1] = cat
        elseif v:sub(1,1) == '*' then
          local field = { labels = {}}
          local c = tmp:gsub('(%b[])%s*', function(f)
            f = f:sub(2,-2)
            if f:match('^[ xX]$') then
              field.checked = f ~= ' '
            else
              table.insert(field.labels, strip(f))
            end
            return ''
          end):gsub('<(.+)>', function(m)
            field.link = m
            return ''
          end)
          field.text = strip(c)
          table.insert(data[#data], field)
        end
      end
    until 1
  end
  
  return options, data
end

require('weblit-app')
  
  .bind({
    host = config.host,
    port = config.port
  })

  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))

  
  .route({
    method = "GET",
    path = "/:path:"
  }, static('assets/www'))
  .route({
    method = "GET",
    path = "/:user"
  }, function (req, res, go)
    for _, path in ipairs(config.paths) do
      local fd = io.open(path:format(req.params.user), 'r')
      if fd then
        local all = {}
        fd:read('*a'):gsub('<%-%-.-%-%->', ''):gsub('[^\n]+',
          function(m)
            m = strip(m:gsub('%[comment%].*', ''):gsub('<>.*', ''))
            if #m > 0 then all[#all + 1] = m end
          end)
        fd:close()
        
        local o, d = parse(all)
        local status, runtime = pcall(template.compile('assets/todo.html'),
          {
            options = o, data = d,
            std = standard,
            style = style
          })
        if status then
          res.code = 202
          res.headers['Content-Type'] = 'text/html'
          res.body = runtime
        else
          res.code = 505
          res.body = 'Internal Server Error: '..runtime
        end
        return
      end
    end
  end)

  .start()