# Slidev Format Quick Reference

## File Structure

Each presentation is a single `slides.md` file. Slides are separated by `---` on its own line.

## Headmatter (first slide's frontmatter = global config)

```yaml
---
theme: seriph          # theme name
title: My Talk         # presentation title
info: |                # metadata
  Description here
class: text-center     # CSS classes for first slide
drawings:
  persist: false
transition: slide-left # default transition
---
```

## Per-Slide Frontmatter

```yaml
---
layout: center         # layout name
background: /image.png # background image (from /public/)
class: text-white      # CSS classes
transition: fade       # override default transition
---
```

## Built-in Layouts

- `default` — standard slide with content
- `center` — centered content
- `cover` — cover/title slide
- `intro` — introduction slide
- `image-right` — image on the right, content on left
- `image-left` — image on the left, content on right
- `image` — full image as background
- `two-cols` — two-column layout (use `::left::` and `::right::` slots)
- `section` — section divider
- `statement` — statement/quote
- `fact` — big fact/number
- `quote` — quote layout
- `end` — end slide

## Slots (for multi-column layouts)

```markdown
---
layout: two-cols
---

# Left column

::right::

# Right column
```

## Images

Place images in the project's `public/` directory. Reference them with absolute paths:

```markdown
![Alt text](/image.png)
```

Or as backgrounds in frontmatter:

```yaml
---
background: /image.png
---
```

## Code Blocks

````markdown
```ts {2-3|5}
// highlighted lines 2-3, then 5
const a = 1
const b = 2
const c = 3
console.log(a + b + c)
```
````

## Styling with UnoCSS

```markdown
<div class="text-3xl font-bold text-blue-500 mb-4">
  Styled text
</div>
```

## Notes (speaker notes)

```markdown
---

# Slide content

<!--
These are speaker notes.
They appear in presenter mode.
-->
```

## Build CLI

```bash
# Development
slidev slides.md

# Build static SPA
slidev build --base /slug/ --out /path/to/output

# Export to PDF
slidev export slides.md
```

## Aspect Ratio

Default is 16:9 (980x552px). Can be changed in headmatter:

```yaml
---
aspectRatio: '16/9'
canvasWidth: 980
---
```
