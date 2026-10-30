# Generating PDF Versions of DHQ Articles

This update adds PDF generation to the DHQ static-site build process. PDFs are generated from the HTML versions of articles using headless Google Chrome or Chromium.

The implementation uses Apache Ant and Chrome/Chromium directly, without requiring Node.js, Playwright, or additional Java libraries.

## How It Works

The PDF generation process:

1. Builds the DHQ static site using the existing `generateSite` target.
2. Identifies generated article HTML files.
3. Invokes headless Chrome/Chromium to render each article as a PDF.
4. Writes the PDFs to `${toDir.base.path}/pdf/`.

Because PDFs are generated from the HTML, they use the site's existing print stylesheet (`print.css`).

PDF filenames correspond to article IDs:

```text
000830.html → 000830.pdf
000831.html → 000831.pdf
```

## Requirements

- Apache Ant
- Google Chrome or Chromium
- The existing DHQ static-site build environment

The location of the Chrome/Chromium executable is configured using the `chromium.path` Ant property.

For example, on macOS:

```text
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome
```

Windows: 

```
C:\Program Files\Google\Chrome\Application\chrome.exe
```

Linux: 

```
/usr/bin/google-chrome
```

If Chrome/Chromium cannot be found at the configured location, the build fails with an explanatory message.

## Usage

### Generate PDFs for All Articles

```bash
ant -lib common/lib/saxon generatePdfs
```

This builds the static site and generates PDFs for all matching article HTML files.

### Generate PDFs for Selected Articles

Create a plain-text file containing one six-digit article ID per line, for example `article.list.txt`:

```text
000830
000831
000845
```

Run:

```bash
ant -lib common/lib/saxon \
    -Dpdf.article.list=/path/to/articles.txt \
    generatePdfs
```

Only articles specified in the list will be processed. If an article ID does not correspond to an existing generated HTML file, it is silently skipped; missing articles do not cause the build to fail.

### Override the Chrome/Chromium Executable

```bash
ant -lib common/lib/saxon \
    -Dchromium.path="/path/to/chrome" \
    generatePdfs
```

## Ant Targets

Four targets support PDF generation:

| Target | Purpose |
|---|---|
| `preparePdfArticleList` | Converts an optional list of article IDs into Ant fileset include patterns. |
| `generateAllPdfs` | Generates PDFs for all matching article HTML files. |
| `generateSelectedPdfs` | Generates PDFs for articles specified in the optional list. |
| `generatePdfs` | Main entry point; coordinates site generation, article selection, and PDF generation. |

The `generatePdfs` target depends on:

```xml
depends="generateSite,preparePdfArticleList,generateAllPdfs,generateSelectedPdfs"
```

Ant's `if` and `unless` attributes ensure that only the appropriate PDF generation target executes.

### Article Selection

When `pdf.article.list` is specified, `preparePdfArticleList` converts article IDs into file patterns.

For example:

```text
000830
000831
```

becomes:

```text
vol/*/*/000830/000830.html
vol/*/*/000831/000831.html
```

These patterns are written to `pdf-article-patterns.txt` and used by `generateSelectedPdfs`.

Without an article list, `generateAllPdfs` uses the pattern:

```text
vol/*/*/*/*.html
```

## Output

Generated PDFs are written to:

```text
${toDir.base.path}/pdf/
```

In the current development environment, this corresponds to `dhq-static/pdf/`. All PDFs are stored in this directory rather than reproducing the HTML directory hierarchy.

## Implementation Notes

- Chrome/Chromium runs in headless mode.
- PDF headers and footers added by Chrome are disabled.
- Each article is processed individually using Ant's `<apply>` task.
- Ant's `<regexpmapper>` maps article HTML filenames to PDF filenames.
- The `<apply>` task uses `failonerror="true"`, so a Chrome process returning a nonzero exit status causes the build to fail.
- Chrome may emit macOS display-related warnings (`CVDisplayLinkCreateWithCGDisplay failed`) during PDF generation. These have not prevented successful PDF creation in testing.

## Current Limitations

**Multilingual articles:** The current implementation generates one PDF per HTML article. Articles containing multiple language versions are not yet handled separately.

**Missing article IDs:** IDs in an article list that do not match generated HTML files are skipped without individual warnings.

**Performance:** Chrome/Chromium is invoked separately for each article. This works but may be relatively slow when generating PDFs for the complete journal.

**Incremental generation:** The build has not yet been optimized to avoid unnecessary PDF regeneration when the static site is rebuilt.

These limitations can be addressed in future updates without changing the basic PDF generation approach.
