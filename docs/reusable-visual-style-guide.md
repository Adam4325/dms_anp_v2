# Reusable Visual Style Guide

Use this compact baseline when another internal program needs the EasyGo visual
language. Keep its own brand/content rules authoritative; do not copy Sales
domain terms, data, or workflows.

## Typography

- Load `Inter` for UI, body, controls, tables, and data; use a system sans-serif
  fallback.
- Load `Montserrat` for page, section, card, dialog, and state headings only.
- Body is 14px / 20px; supporting text is 12px / 16px; do not use body text
  below 12px.
- Use tabular numerals for dates, quantities, money, percentages, and KPIs.

## Tokens and surfaces

```text
nav #0B1220          workspace #F7F8FA     surface #FFFFFF
surface subtle #F9FAFB
text primary #101828 secondary #475467 muted #667085 disabled #98A2B3
border #E4E7EC       strong border #D0D5DD
brand orange #F36A21 hover #DA5916 press #C84E12 soft #FFF4ED
success #16A34A      warning #D97706       danger #DC2626       info #2563EB
```

- Use the workspace background with a restrained orange top-right wash; keep
  dense data areas on white surfaces.
- Use only the 4, 8, 12, 16, 20, 24, 32, 40, 48, and 64px spacing scale.
- Buttons/inputs use 8px radius; cards 12px; overlays 14px; badges are pills.
- Prefer borders and spacing over heavy shadows.

## Controls and links

- Primary action: orange fill and white label. Secondary: white with strong
  border. Ghost: transparent with secondary text. Default/compact/large
  heights are 40/32/44px.
- A pointer/touch action needs visible hover, focus, pressed, disabled,
  loading, success, and error behavior where applicable. Loading prevents
  duplicate submission and exposes `aria-busy`.
- Links are visibly underlined on hover and keyboard focus; never rely on
  color alone.
- Use a 2px visible focus ring with offset. Touch targets are at least 40×40px.

## Tables and responsive actions

- Header/body geometry: 40–44px header, 48px readable rows, 12–16px horizontal
  and 10–12px vertical cell padding. Align text left and numeric values right.
- Wrap a wide table in a local horizontal scroller; never create page-level
  sideways scrolling. Keep key columns and actions discoverable.
- Do not allow card-header action positioning rules to affect row actions.
  Row-action containers reset their margin, wrap safely, and keep a minimum
  usable button width.
- At narrow widths, convert action-heavy rows into compact labelled row cards:
  retain the task/name and due/status summary, place actions in a full-width
  two-column grid, and raise compact action targets to 40px. Do not hide
  actions behind hover-only affordances or require horizontal scrolling to
  discover them.

## States and accessibility

- Provide distinct loading, empty, error, success, and disabled states. Do not
  show unknown values as zero.
- Maintain WCAG AA contrast, semantic labels, keyboard operation, visible focus,
  and non-color status cues. Respect `prefers-reduced-motion`.
- Test at 1440×900, 1280×768, 1024×768, 390×844, and at least 360px width.
  Check no horizontal page overflow, readable tables, visible actions, and
  keyboard focus before release.
