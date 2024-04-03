The toc.xml file is used to generate tables of contents.

The root element for any table of contents xml file is <toc>

A <toc> element optionally contains a <journal> child element, which includes
an optional:
- @vol : volume number
- @issue : issue number
- @current : flag to indicate which is the current issue
- @preview : flag to indicate which is the preview
- @editorial : flag to indicate which is the editorial

A <toc> element optionally contains a <title> child element, which includes
an optional:
- @value : date value in the format YYYY-MM-DD

A <toc> element has an optional <specialTitle> child element.

A <toc> element has an optional <cluster> child element, which
includes:
- a required <title> child element
- an optional <editors> child element
- at least one <item> child element or at least one <list> section child element
A <cluster> generates a sort-of miniature issue under a "Clusters"
heading.

A <list> element contains an @id which indicates the type of list section.
Current @id values are:
- frontmatter (Front Matter)
- articles (Articles)
- posters (Posters)
- reviews (Reviews)
- issues (Issues in Digital Humanities)
- editorials (Editorials)
Each <list> contains at least one <item> child element.
Each <item> must have an @id with a value (empty @id value will break the TOC)

An <editors> element contains an optional @n to indicate the number
of editors listed in the content.
When @n = 1, the singular "Editor:" is used, otherwise the plural
"Editors:" is used.

A <toc> element has an optional <list> child element, which requires:
- @id whose values may be: frontmatter|editorials|articles|issues|reviews
- at least one <item> child element

An <item> is a blank element, containing only a required six digit @id to
indicate the article ID number. ID numbers are sequentially numbered, but
do not have to be ordered sequentially. Their order within the table of
contents XML file dictates their order in the generated table of contents.