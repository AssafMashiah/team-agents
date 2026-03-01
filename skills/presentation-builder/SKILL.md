# Skill: Presentation Builder

Build polished slide presentations with a data-first workflow. Content lives in `data.md`, design decisions come from Gemini Flash, and everything is version-controlled in a GitHub repo.

## Trigger

When the user asks to create a presentation, build slides, or sends content for conversion to slides.

## Pipeline

### 1. Receive Input + Choose Slug

Accept content from any source (message, file, direct instruction). Derive a short URL-safe slug from the title — lowercase, hyphens, no spaces.

Examples:
- "Q1 Results 2026" → `q1-results-2026`
- "Intro to Kubernetes" → `intro-to-kubernetes`

If `~/Documents/AssafMashiah/slides/{slug}/` already exists, ask the user if they want to overwrite (new version) or pick a new slug.

### 2. Init GitHub Repo (one-time)

The slides live in `AssafMashiah/slides` on GitHub. If the repo doesn't exist locally:

```bash
bash ~/Documents/thrallboy/jade/skills/presentation-builder/scripts/init_slides_repo.sh
```

This creates the repo on GitHub (if needed), clones it, and sets up `.gitignore` and `README.md`. Only runs once — skip if `~/Documents/AssafMashiah/slides/.git` exists.

### 3. Create Deck Folder

```bash
SLUG="the-slug"
SLIDES_REPO="$HOME/Documents/AssafMashiah/slides"
DECK="$SLIDES_REPO/$SLUG"
mkdir -p "$DECK/public"
cp ~/Documents/thrallboy/jade/skills/presentation-builder/assets/slidev-template/package.json "$DECK/"
```

### 4. Write data.md

Create `$DECK/data.md` — the **source of truth** for content. This is pure content markdown with no Slidev syntax. Structure:

```markdown
# Presentation Title

Subtitle or tagline

---

## Slide Title
Type: content

- Bullet point one
- Bullet point two
- Bullet point three

---

## Big Visual Slide
Type: cover
Image hint: abstract geometric landscape, warm sunset tones

Welcome to the presentation

---

## Two Things Compared
Type: comparison

Left:
- Feature A
- Feature B

Right:
- Feature X
- Feature Y

---

## Code Example
Type: code

\```python
def hello():
    print("world")
\```

---

## Key Takeaways
Type: section

Three things to remember...
```

**Slide types** (semantic, not visual):
- `cover` — title/hero slide
- `content` — standard bullets/text
- `section` — section divider or transition
- `code` — code-focused slide
- `comparison` — side-by-side content
- `fact` — single big number or statement
- `quote` — quotation
- `end` — closing slide

**Rules**:
- Preserve the user's content and message — organize, don't rewrite
- Keep slides concise (3-5 bullets max)
- `Image hint:` is optional — describes what image to generate for that slide
- Slide separators are `---` on their own line

### 5. Generate Design System

Call Gemini Flash to analyze `data.md` and produce a design system JSON.

**API call:**

```bash
GEMINI_API_KEY=$(grep GEMINI_API_KEY "$HOME/.openclaw/gemini-api-key.env" | cut -d= -f2)

curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "PROMPT_WITH_DATA_MD_CONTENT"}]}],
    "generationConfig": {
      "responseMimeType": "application/json",
      "responseSchema": {
        "type": "object",
        "properties": {
          "palette": {
            "type": "object",
            "properties": {
              "primary": {"type": "string"},
              "secondary": {"type": "string"},
              "accent": {"type": "string"},
              "background": {"type": "string"},
              "surface": {"type": "string"},
              "text": {"type": "string"},
              "textLight": {"type": "string"}
            },
            "required": ["primary", "secondary", "accent", "background", "surface", "text", "textLight"]
          },
          "fonts": {
            "type": "object",
            "properties": {
              "heading": {"type": "string"},
              "body": {"type": "string"},
              "code": {"type": "string"}
            },
            "required": ["heading", "body", "code"]
          },
          "mood": {"type": "string"},
          "imageStyle": {"type": "string"},
          "customCSS": {"type": "string"},
          "slides": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "index": {"type": "integer"},
                "layout": {"type": "string"},
                "classes": {"type": "string"},
                "background": {"type": "string"},
                "notes": {"type": "string"}
              },
              "required": ["index", "layout"]
            }
          }
        },
        "required": ["palette", "fonts", "mood", "imageStyle", "customCSS", "slides"]
      }
    }
  }'
```

**Prompt template** (include the full `data.md` content):

```
You are a presentation design system generator. Given the following presentation content, produce a cohesive design system.

Requirements:
- palette: hex colors that match the topic and mood. primary = main brand/accent, background = slide bg, surface = card/box bg
- fonts: Google Fonts names. Choose fonts that match the mood (e.g., "Poppins" for modern, "Playfair Display" for elegant)
- mood: one-line description of the visual feeling (e.g., "clean and corporate", "bold and playful")
- imageStyle: Imagen prompt prefix for visual consistency (e.g., "flat illustration, minimal, soft gradients")
- customCSS: a CSS block targeting Slidev's .slidev-layout class for global styles (font imports, heading colors, etc.)
- slides: per-slide layout strategy. Use Slidev layout names: cover, center, default, image-right, image-left, two-cols, section, fact, quote, end. Add UnoCSS classes in "classes" field.

Content:
---
{DATA_MD_CONTENT}
---
```

Save the response as `$DECK/design-system.json`.

**Fallback**: If the API call fails, copy the default design system:
```bash
cp ~/Documents/thrallboy/jade/skills/presentation-builder/assets/default-design-system.json "$DECK/design-system.json"
```

**SECURITY**: Never expose the API key in workspace files, logs, or user-facing output.

### 6. Generate Images

Use the Gemini Imagen API to generate images for slides that need them.

**Which slides get images:**
- Slides with `Image hint:` in `data.md`
- Cover/title slides (hero image or abstract background)
- Section dividers (thematic imagery)

**Skip images for:**
- Code slides
- Data/table slides
- Bullet-heavy slides (text is the content)

**Prompt construction**: Combine the slide's `Image hint:` (or a generated description) with the design system's `imageStyle` and palette for visual consistency:

```
{imageStyle}, {image_hint}, color palette featuring {primary} and {secondary}, 16:9 aspect ratio, no text
```

**API call:**

```bash
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [{"prompt": "CONSTRUCTED_PROMPT"}],
    "parameters": {
      "sampleCount": 1,
      "aspectRatio": "16:9"
    }
  }'
```

Decode `predictions[].bytesBase64Encoded` and save:
```bash
echo "$BASE64_DATA" | base64 -d > "$DECK/public/slide-N.png"
```

**Fallback**: If generation fails, proceed without the image. Add `<!-- image generation failed -->` in the slide. Don't block the build.

### 7. Build Slidev Skeleton

Create `$DECK/slides.md` with structure only — no content yet. Use the design system's per-slide layout info:

```markdown
---
theme: seriph
title: {title from data.md}
info: |
  Built by Jade
drawings:
  persist: false
transition: slide-left
---

{empty — content injected in step 8}

---
layout: {from design-system.slides[1].layout}
class: {from design-system.slides[1].classes}
---

{empty}

---
...
```

### 8. Fill In Content

Inject `data.md` content into the skeleton:
- Map each slide's content from `data.md` into the corresponding skeleton slot
- Apply design system styling:
  - Global `<style>` block at the end with `customCSS` from design system
  - UnoCSS arbitrary value classes where needed (e.g., `text-[#hex]`, `bg-[#hex]`)
  - Image references (`/slide-N.png`) for slides that got images (as `background:` in frontmatter or inline `![](/slide-N.png)`)
- For `comparison` type slides, use `layout: two-cols` with `::right::` slot
- For `code` type slides, preserve code blocks with language tags
- For `fact` type slides, use `layout: fact` or `layout: statement`

**Content rules** (same as before):
- Keep slides concise — 3-5 bullet points max
- Use `#` for slide titles, `##` for subtitles
- Preserve the user's content — enhance formatting, don't rewrite

### 9. Build Static SPA

```bash
bash ~/Documents/thrallboy/jade/skills/presentation-builder/scripts/build_presentation.sh "$DECK" "$SLUG"
```

This runs `npx slidev build` and outputs to `~/Documents/thrallboy/presentations/builds/{slug}/`.

### 9b. Upload to R2

Run the upload script to back up the build to the `slides-builds` R2 bucket:

```bash
bash ~/Documents/thrallboy/jade/skills/presentation-builder/scripts/upload_to_r2.sh "$SLUG"
```

This uploads all files under `~/Documents/thrallboy/presentations/builds/{slug}/` to `r2://slides-builds/{slug}/` with correct `Content-Type` headers.

### 10. Commit + Push

```bash
cd "$HOME/Documents/AssafMashiah/slides"
git add "$SLUG/"
git commit -m "feat($SLUG): V1"
git push
```

For updates to an existing deck:
```bash
git add "$SLUG/"
git commit -m "update($SLUG): <brief description>"
git push
```

### 11. Report URLs

Tell the user:
```
Presentation ready!
  Public:  https://slides.thrallboy.com/{slug}/
  Local:   http://localhost:3030/{slug}/
  GitHub:  https://github.com/AssafMashiah/slides/tree/main/{slug}
  Content: https://github.com/AssafMashiah/slides/blob/main/{slug}/data.md
```

## Repo Structure

```
~/Documents/AssafMashiah/slides/          ← GitHub repo (AssafMashiah/slides)
├── .gitignore
├── README.md
├── {slug}/
│   ├── data.md                        ← Content source of truth
│   ├── design-system.json             ← Gemini Flash output
│   ├── slides.md                      ← Final Slidev deck
│   ├── package.json                   ← Slidev dependencies
│   └── public/
│       ├── slide-1.png                ← Generated images
│       └── slide-3.png
└── {another-slug}/
    └── ...

~/Documents/thrallboy/presentations/
└── builds/                            ← Static builds (served by HTTP, NOT in git)
    └── {slug}/
        └── index.html (+ assets)
```

## Design System Schema

The `design-system.json` file follows this structure:

```json
{
  "palette": {
    "primary": "#2563EB",
    "secondary": "#1E40AF",
    "accent": "#F59E0B",
    "background": "#FFFFFF",
    "surface": "#F1F5F9",
    "text": "#1E293B",
    "textLight": "#64748B"
  },
  "fonts": {
    "heading": "Inter",
    "body": "Inter",
    "code": "Fira Code"
  },
  "mood": "clean and professional",
  "imageStyle": "flat illustration, minimal, soft gradients, corporate style",
  "customCSS": ".slidev-layout { font-family: 'Inter', sans-serif; } .slidev-layout h1 { color: #2563EB; }",
  "slides": [
    { "index": 0, "layout": "cover", "classes": "text-center", "background": "/slide-0.png" },
    { "index": 1, "layout": "default", "classes": "" },
    { "index": 2, "layout": "two-cols", "classes": "", "notes": "use ::right:: slot" }
  ]
}
```

## Tips

- `data.md` is what you edit for content changes — `slides.md` is regenerated from it
- Run `npx slidev $DECK/slides.md` to preview locally during development
- The `serve` process on port 3030 auto-serves new builds — no restart needed
- For updates: edit `data.md`, regenerate `slides.md`, rebuild, commit with `update()` message
- Keep generated images at 16:9 to match Slidev's default canvas
- The `seriph` theme is the default — clean and professional
- Git history is the version history — no branches, just commits on `main`

## Error Handling

- **npm install fails**: Check Node version (needs v22+), try clearing `node_modules` and retrying
- **slidev build fails**: Check `slides.md` syntax — common issues are unclosed code blocks or bad frontmatter YAML
- **Gemini Flash fails**: Use `default-design-system.json` as fallback, continue the build
- **Imagen API fails**: Log the error, skip the image, continue the build
- **Port 3030 not responding**: Check `launchctl list | grep slides` — reload the LaunchAgent if needed
- **Git push fails**: Check SSH keys / auth, try `gh auth status`
