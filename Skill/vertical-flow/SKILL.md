---
name: vertical-flow
description: Use this skill when code is hard to read. The problem is usually horizontal: too much on one line. Fix it by stacking one idea per line down the page.
---

# Vertical Flow

> Use this skill when code is hard to read. The problem is usually horizontal: too much on one line. Fix it by stacking one idea per line down the page.


## Optimizing for the Y-axis

> Vertical flow writes for the constrained viewport. 

- It uses principles of readability to optimize the Y-axis and limit the X-axis.

> Each line carries one idea.

- Lines stay narrow and focused.

> Content stacks down the page, not horizontally.

- The text should be easily scannable on a phone. 

> Implement line length constraints.

- Use structural hierarchies to promote readable visuals.

---

## ViewPort Constraint

```powershell
switch ($chat) {
    'gpt' {
        Read-GptChatPrompt
    }
    'gemini' {
        Read-GeminiChatPrompt
    }
    'gpt-oss-20b' {
        Invoke-LlamaCli
    }
}
```

Vertical flow helps ensure infinite scroll without cognitive cost.

### Line Length 

Below is an example line length constraint for markdown source:

```markdown
Headers: 20-40 characters
Prose: 60-80 characters
Code: viewport width maximum
Lists: use markdown lists, **NOT** inline
```

### As content flows down the screen

#### _The reader should encounter_

### ZeroCost Thumb Navigation 

> Now, read the previous 4 lines again: As content flows down the screen _the reader should encounter_ zero cost thumb navigation.

The previous line is the same content written differently to ensure readability on a mobile device.

```powershell
function psnx {
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'all', 
            'test',
            'compile', 
            'profile', 
            'chat', 
            'core', 
            'reactor',
            'document', 
            'install', 
            'clean',
            'manifest', 
            'analyze')]
        [string]$task,
}
```

---

 Each section should fit within the viewport width.

---

## Scan Pattern

> Vertical flow stacks information vertically.

- Headers mark navigation points.
- Code blocks serve as anchors.
- Whitespace separates concepts.

> Line length is strictly bounded.

- Prose flows down, never across.
- The structure survives mobile viewports.

---

## Progressive Information Density

> Present information in layers, from identity to proof.

1. Core identity
2. Type definitions
3. Operational protocol
4. Executable examples

---

## Chunking Strategy

> Each visual block carries one idea.

- Keep about three lines per concept.
- Use whitespace generously between blocks.

---

## Requirements

### Line Length

- Headers should remain under 60 characters.
- Prose should remain under 80 characters.
- Code blocks should avoid horizontal scroll when possible.

### Stacking

- Information should flow vertically.
- Related concepts should stack in reading order.
- Whitespace should separate logical sections.

### Hierarchy

- Code definitions should precede explanations.
- Lists should contain single-line items.

### Chunking

- Each block should contain one primary concept.
- Blocks should be self-contained.
- Navigation should require only vertical scroll.

---

## Anti Patterns

- Avoid wide tables.
- Avoid inline parenthetical descriptions.
- Avoid colon suffixes on headers.
- Avoid dense paragraphs in place of stacked lines.
- Avoid layouts that require horizontal scrolling.

---

## Validation Pattern

```bash
# Test on mobile device

- Can I read without zooming?
- Can I scroll with thumb only?
- Can I edit without horizontal navigation?

# All answers should be: Yes
```
