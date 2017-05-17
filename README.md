# ToDoList
A simple markdown-inspired todo list viewer written in **Lua** ([Demo](https://ode.bz/todo/lazyshpee))
This uses luvit (backend) , Bootstrap 3, Bootflat and Font Awesome (frontend)
---
### Installation
Install [luvit and lit](https://luvit.io/install.html)
```
git clone git@github.com:LazyShpee/todolist.md.git && cd todolist.md
lit install
cp config.example.lua config.lua
luvit todo.lua
```

---
### Config File `config.lua`
| Option | Type | Default Value | Description
|-|-|-|-
|`port`| `int`|`8000`|The port port the app listens on
|`domain`|`string`|`"0.0.0.0"`|Thee domains the app will listen on
|`paths`|`table`|`{"./%s.md"}`|The list of path where the app will look for boards, it will replace `%s` by `http://127.0.0.1:8000/<this>`, use a constant string last for a default board

---
### Board Files
A board file is written in a simple Markdown(tm) inspired syntax.
It is composed of two parts, the board header and the board data

```
name:Your Name
picture:http://placehold.it/64x64

(Panel One){rgb(255, 255, 100)}
[Label 1]{#782534}
<link>{http://example.com}
---
# Panel One
* Item 1 <link>
* [Label 1] [Label 2] Item 2

# Panel Two
* [ ] Unchecked task
* [x] Checked task
* Item 3
* [ ] Indented task for item 3
* [x] Indented task for item 3 with link <link>
```

#### Header
The header is used to set the displayed name, picture, create hyperlinks and change colors.
First, comments are either `[comment] Single line comment`, `<> Other single line comment` or `<-- Multiple line comment -->`
This table list all the `key:value` pairs used by the app.
|Key|Type|Description
|-|-|-
|`name`|string|Name displayed above all the panels
|`picture`|url|Picture displayed with name
|`url`|url|Link that opens when picture or name are clicked
|`link_text`|color|Color of the open link icon
|`item_text`|color|Item text color
|`item_background`|color|Item background color
|`item_separator`|color|Item separator color
|`thumbnail_text`|color|Name text color
|`thumbnail_background`|color|Picture background color
|`label_text`|color|Label text color
|`label_background`|color|Label default background color
|`header_text`|color|Panel header text color
|`header_background`|color|Panel header default color
|`body_background`|color|Body background color
The *color* type is either a HTML color name (eg. `white`), a hexadecimal color (eg. `#FAD123`) or rgb notation (eg. `rgb(120, 230, 50)`)
Beside those settings, there are three other customisation possible:
* Panel header color `(Panel name){color}`
* Label color `[Label name]{color}`
* Links, declared like this: `<link name>{http://example.com}`, to use them write `<link name>` at the end of an item text

#### Board Data
Panel: `# Panel Name`
Item: `* [Label name] Item text`
Items can have zero or more labels. If a label name is either a ` ` (space), an `x` (case unsensitive), the item will instead be a task marked with a checkbox. If a serie of tasks are preceded by one or more regular items, they will be indented.