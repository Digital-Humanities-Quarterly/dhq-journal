Data files for DHQ Bibliography Project
=======================================

Files:

dhq_articles.tsv

This table includes a row for each DHQ article. More rows are forthcoming. What is currently available are those articles whose bibliographies have been edited to include links to the canonical DHQ bibliographical data, i.e., the Biblio data.

works_cited_in_dhq.tsv

This table includes a row for each work that is cited by DHQ articles. 

Each table has the following columns:

* article id [Biblio ID in works_cited_in_dhq.tsv; DHQ ID in dhq_articles.tsv]
* author
* year
* title
* journal/conference/collection [title of journal, conference, or monograph in which the work appears]
* abstract [only populated in dhq_articles.tsv]
* reference IDs [IDs of all the works cited by an individual DHQ article; only relevant and populated in dhq_articles.tsv]
* isDHQ [Boolean: 1/true means it's a DHQ article; 0/false means it is not; populated in both tables but redundant in dhq_articles.tsv, since these are all dHQ articles]