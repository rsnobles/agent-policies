# Documentation guide

How to write and file documentation in this repository. Adapted from GitHub's [internal-documentation-example](https://github.com/github/internal-documentation-example).

## Where should my document go?

- Docs about this repo, its design and its use go in `docs/`, one flat file per subject, listed in [docs/README.md](README.md).
- Notes about a specific machine, account, vault or past bot go in `local/`, which Git ignores. Never link to `local/` from a tracked file.
- Name things by subject, not by a numbered requirement. Define any new term or ID in the [glossary](glossary.md).
- Record a decision in [decisions.md](decisions.md); keep open work in [roadmap.md](roadmap.md).

## House style

- Use real headings (`##`, `###`). Never use bold or emphasis as a heading (markdownlint MD036).
- Put every command in its own fenced block with a language tag, usually `bash`, so it gets a copy button.
- Keep the overview visible. Fold long or secondary material (full trees, large tables, long schemas, logs) into a `<details>` block with a descriptive summary.
- Leave a blank line after `</summary>` and before `</details>`, or the Markdown inside will not render.
- Be concise; favor tables and short lists over long paragraphs.
- Run `make lint` before committing.

A collapsible section:

```html
<details>
<summary>Full directory tree</summary>

Markdown here: tables, lists and fenced code all render.

</details>
```

## Templates

- [Feature documentation template](feature-template.md)
